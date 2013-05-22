require 'rack/in-app-purchase'

require 'sinatra/base'
require 'sinatra/param'

class Helios::Backend::InAppPurchase < Sinatra::Base
  helpers Sinatra::Param

  def initialize(app, options = {}, &block)
    super(Rack::InAppPurchase.new)
  end

  before do
    content_type :json
  end

  helpers Sinatra::Param

  get '/receipts' do
    param :q, String

    receipts = Rack::InAppPurchase::Receipt.dataset
    receipts = receipts.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?

    if params[:page] or params[:per_page]
      param :page, Integer, default: 1, min: 1
      param :per_page, Integer, default: 100, in: (1..100)

      {
        receipts: receipts.limit(params[:per_page], (params[:page] - 1) * params[:per_page]).naked.all,
        page: params[:page],
        total: receipts.count
      }.to_json
    else
      param :limit, Integer, default: 100, in: (1..100)
      param :offset, Integer, default: 0, min: 0

      {
        receipts: receipts.limit(params[:limit], params[:offset]).naked.all
      }.to_json
    end
  end
end
