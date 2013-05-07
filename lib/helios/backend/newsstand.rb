require 'rack'
require 'rack/newsstand'

require 'sinatra/base'
require 'sinatra/param'

require 'fog'

class Helios::Backend::Newsstand < Sinatra::Base
  helpers Sinatra::Param

  def initialize(app, options = {})
    super(Rack::Newsstand.new)

    @storage = Fog::Storage.new(options[:storage]) if options[:storage]
  end

  before do
    content_type :json
  end

  get '/issues/?' do
    pass unless request.accept? 'application/json'

    param :q, String

    issues = Rack::Newsstand::Issue.dataset
    issues = issues.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?

    if params[:page] or params[:per_page]
      param :page, Integer, default: 1, min: 1
      param :per_page, Integer, default: 100, in: (1..100)

      {
        issues: issues.limit(params[:per_page], (params[:page] - 1) * params[:per_page]).naked.all,
        page: params[:page],
        total: issues.count
      }.to_json
    else
      param :limit, Integer, default: 100, in: (1..100)
      param :offset, Integer, default: 0, min: 0

      {
        issues: issues.limit(params[:limit], params[:offset]).naked.all
      }.to_json
    end
  end

  head '/issue/?' do
    status 503 and return unless @storage

    status 204
  end

  post '/issues/?' do
    status 503 and return unless @storage

    param :title, String, empty: false
    param :name, String, empty: false
    param :summary, String, empty: false

    @issue = Rack::Newsstand::Issue.new(params)

    if @issue.save
      directory = @storage.directories.create(key: "issue-#{@issue.name}", public: true)

      [:covers, :assets].each do |attribute|
        (params[attribute] || []).each do |filename|
          file = directory.files.create(
            key: File.basename(filename),
            body: File.open(filename),
            public: true
          )
          @issue[attribute] << file.url
        end
      end

      if @issue.save
        status 201
        @issue.to_json
      else
        status 400
        {errors: @issue.errors}.to_json
      end
    else
      status 400
      {errors: @issue.errors}.to_json
    end
  end
end
