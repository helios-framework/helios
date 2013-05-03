require 'rack'
require 'rack/newsstand'

require 'sinatra/base'
require 'sinatra/param'

require 'fog'

class Helios::Backend::Newsstand < Sinatra::Base
  helpers Sinatra::Param

  def initialize(app, options = {})
    super(Rack::Newsstand.new)

    @storage = Fog::Storage.new(options[:storage])
  end

  before do
    content_type :json
  end

  get '/issues/?' do
    pass unless request.accept? 'application/json'

    issues = Rack::Newsstand::Issue.dataset

    if params[:page] or params[:per_page]
      param :page, Integer, default: 1, min: 1
      param :per_page, Integer, default: 100, in: (1..100)

      {
        passes: issues.limit(params[:per_page], (params[:page] - 1) * params[:per_page]).naked.all,
        page: params[:page],
        total: issues.count
      }.to_json
    else
      param :limit, Integer, default: 100, in: (1..100)
      param :offset, Integer, default: 0, min: 0

      {
        passes: issues.limit(params[:limit], params[:offset]).naked.all
      }.to_json
    end
  end

  head '/issue/?' do
    status 503 and return unless @storage

    status 204
  end

  post '/issue/?' do
    status 503 and return unless @storage

    param :name, String, empty: false
    param :description, String, empty: false

    # TODO
    directory = @storage.directories.create(key: "issue-#{issue.name}", public: true)

    file = directory.files.create(
      key: 'resume.html',
      body: File.open("/path/to/my/resume.html"),
      public: true
    )
  end
end
