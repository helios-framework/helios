require 'rack/passbook'

require 'sinatra/base'
require 'sinatra/param'
require 'rack/contrib'

class Helios::Backend::Passbook < Sinatra::Base
  helpers Sinatra::Param
  use Rack::PostBodyContentTypeParser

  def initialize(app, options = {}, &block)
    super(Rack::Passbook.new)
  end

  before do
    content_type :json
  end

  # query for all passes
  get '/passes' do
    param :q, String

    passes = Rack::Passbook::Pass.dataset
    passes = passes.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?

    if params[:page] or params[:per_page]
      param :page, Integer, default: 1, min: 1
      param :per_page, Integer, default: 100, in: (1..100)

      {
        passes: passes.limit(params[:per_page], (params[:page] - 1) * params[:per_page]).naked.all,
        page: params[:page],
        total: passes.count
      }.to_json
    else
      param :limit, Integer, default: 100, in: (1..100)
      param :offset, Integer, default: 0, min: 0

      {
        passes: passes.limit(params[:limit], params[:offset]).naked.all
      }.to_json
    end
  end

  # get latest version of pass
  get '/v1/passes/:pass_type_identifier/:serial_number/?' do
    @pass = Rack::Passbook::Pass.filter(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    halt 404 if @pass.nil?
    filter_authorization_for_pass!(@pass)

    last_modified @pass.updated_at.utc

    # THIS NEEDS TO BE A .PKPASS FILE, NOT JSON
    @pass.to_json
  end

  # Get the serial numbers for passes associated with a device.
  # This happens the first time a device communicates with our web service.
  # Additionally, when a device gets a push notification, it asks our
  # web service for the serial numbers of passes that have changed since
  # a given update tag (timestamp).
  get '/v1/devices/:device_library_identifier/registrations/:pass_type_identifier/?' do
    @passes = Rack::Passbook::Pass.filter(pass_type_identifier: params[:pass_type_identifier]).join(Rack::Passbook::Registration.dataset, device_library_identifier: params[:device_library_identifier])
    halt 404 if @passes.empty?

    updatedSince = Date.parse(params[:passesUpdatedSince]) if params[:passesUpdatedSince]
    @passes = @passes.where('passbook_passes.updated_at > ?', updatedSince) if params[:passesUpdatedSince]

    if @passes.any?
      {
        lastUpdated: @passes.collect(&:updated_at).max,
        serialNumbers: @passes.collect(&:serial_number).collect(&:to_s)
      }.to_json
    else
      halt 204
    end
  end

  # Register a device to receive push notifications for a pass.
  post '/v1/devices/:device_library_identifier/registrations/:pass_type_identifier/:serial_number/?' do
    @pass = Rack::Passbook::Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    halt 404 if @pass.nil?
    filter_authorization_for_pass!(@pass)

    param :pushToken, String, required: true

    @registration = @pass.registrations.detect{|registration| registration.device_library_identifier == params[:device_library_identifier]}
    @registration ||= Rack::Passbook::Registration.new(pass_id: @pass.id, device_library_identifier: params[:device_library_identifier])
    @registration.push_token = params[:pushToken]

    status = @registration.new? ? 201 : 200

    @registration.save
    halt 406 unless @registration.valid?

    halt status
  end

  # Unregister a device so it no longer receives push notifications for a pass.
  delete '/v1/devices/:device_library_identifier/registrations/:pass_type_identifier/:serial_number' do
    @pass = Rack::Passbook::Pass.filter(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
    halt 404 if @pass.nil?
    filter_authorization_for_pass!(@pass)

    @registration = @pass.registrations.detect{|registration| registration.device_library_identifier == params[:device_library_identifier]}
    halt 404 if @registration.nil?

    @registration.destroy

    halt 200
  end

  private

    def filter_authorization_for_pass!(pass)
      halt 401 if request.env['HTTP_AUTHORIZATION'] != "ApplePass #{pass.authentication_token}"
    end
end
