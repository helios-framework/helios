require 'rack/gcm'

require 'sinatra/base'
require 'sinatra/param'

require 'sanjose'

class Helios::Backend::Gcm < Sinatra::Base
  helpers Sinatra::Param
  attr_reader :gcm_api_key

  def initialize(app, options = {}, &block)
    super(Rack::GCM.new)

    @api_key = options[:gcm_api_key] || ENV['GCM_API_KEY']    
  end

  before do
    content_type :json
  end

  get '/devices/?' do
    param :q, String

    devices = ::Rack::GCM::Device.dataset
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
    record = ::Rack::GCM::Device.find(token: params[:token])

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
    
    tokens = params[:tokens] || ::Rack::GCM::Device.all.collect(&:token)
    
    options = JSON.parse(params[:payload])    
    puts tokens.inspect
    puts options
    
    # Create a notification that alerts a message to the user.
    notification = Sanjose::Notification.new(devices: tokens)
    notification.data = options
    
    begin
      results = client.push(notification)
      
      status 204
    rescue => error
      status 500
      
      {error: error}.to_json
    end
   
    status 200
  end

  private

  def client
    begin
      return nil unless api_key
  
      client = Sanjose::Client.new
      client.gcm_api_key = api_key
  
      return client
    rescue
      return nil
    end
  end
end
