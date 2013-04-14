require 'rack/push-notification'
require 'sinatra/param'
require 'houston'

class Helios::Backend::PushNotification < Sinatra::Base
  helpers Sinatra::Param  

  def initialize(app, options = {})
    super(Rack::PushNotification.new)
    @apn_certificate = options[:apn_certificate]
    @apn_environment = options[:apn_environment]
  end

  def apn_certificate
    @apn_certificate || ENV['APN_CERTIFICATE']
  end

  def apn_environment
    @apn_environment || ENV['APN_ENVIRONMENT']
  end

  get '/devices/?' do
    param :q, String

    devices = ::Rack::PushNotification::Device.dataset
    devices = devices.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?

    if params[:page] or params[:per_page]
      param :page, Integer, default: 1, min: 1
      param :per_page, Integer, default: 100, in: (1..100)

      {
        devices: devices.limit(params[:per_page], (params[:page] - 1) * params[:per_page]),
        page: params[:page],
        total: devices.count
      }.to_json
    else
      param :limit, Integer, default: 100, in: (1..100)
      param :offset, Integer, default: 0, min: 0

      {
        devices: devices.limit(params[:limit], params[:offset])
      }.to_json
    end
  end

  get '/devices/:token/?' do
    record = ::Rack::PushNotification::Device.find(token: params[:token])

    if record
      {device: record}.to_json
    else
      status 404
    end
  end

  head '/message' do
    status 503 and return unless client

    status 204
  end

  post '/message' do
    status 503 and return unless client

    param :payload, String, empty: false
    param :tokens, Array, empty: false

    tokens = params[:tokens] || ::Rack::PushNotification::Device.all.collect(&:token)

    options = JSON.parse(params[:payload])
    options[:alert] = options["aps"]["alert"]
    options[:badge] = options["aps"]["badge"]
    options[:sound] = options["aps"]["sound"]
    options.delete("aps")

    begin
      notifications = tokens.collect{|token| Houston::Notification.new(options.update({device: token}))}
      client.push(*notifications)

      status 204
    rescue => error
      status 500

      {error: error}.to_json
    end
  end

  private

  def client
    begin
      return nil unless apn_certificate and ::File.exist?(apn_certificate)
      
      client = case apn_environment.to_sym
                when :development 
                  Houston::Client.development
                when :production
                  Houston::Client.production
                end
      client.certificate = ::File.read(apn_certificate)

      return client
    rescue
      return nil
    end
  end
end
