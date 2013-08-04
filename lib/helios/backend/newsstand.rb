require 'rack/newsstand'

require 'sinatra/base'
require 'sinatra/param'
require 'rack/contrib'

require 'fog'

class Helios::Backend::Newsstand < Sinatra::Base
  helpers Sinatra::Param
  use Rack::PostBodyContentTypeParser

  def initialize(app, options = {}, &block)
    super(Rack::Newsstand.new)

    @storage = Fog::Storage.new(options[:storage]) if options[:storage]
  end

  before do
    content_type :json
  end

  get '/issues/?' do
    param :q, String

    @issues = Rack::Newsstand::Issue.dataset

    @issues = @issues.filter("tsv @@ to_tsquery('english', ?)", "#{params[:q]}:*") if params[:q] and not params[:q].empty?

    request.accept.each do |type|
      case type.to_s
      when 'application/atom+xml', 'application/xml', 'text/xml'
        content_type 'application/x-plist'
        @issues = @issues.all if @issues.respond_to?(:all)
        return builder :atom
      when 'application/x-plist'
        content_type 'application/plist'
        @issues = @issues.all if @issues.respond_to?(:all)
        return @issues.to_plist
      when 'application/json'
        if params[:page] or params[:per_page]
          param :page, Integer, default: 1, min: 1
          param :per_page, Integer, default: 100, in: (1..100)
          json = {
            issues: @issues.limit(params[:per_page], (params[:page] - 1) * params[:per_page]).naked.all,
            page: params[:page],
            total: @issues.count
          }.to_json

          return json
        else
          param :limit, Integer, default: 100, in: (1..100)
          param :offset, Integer, default: 0, min: 0
          json = {
            issues: @issues.limit(params[:limit], params[:offset]).naked.all
          }.to_json

          return json
        end
      else
        halt 406
      end
    end
  end

  get '/issues/:name/?' do
    pass unless request.accept? 'application/json'

    Rack::Newsstand::Issue.find(name: params[:name]).to_json
  end


  head '/storage' do
    status 503 and return unless @storage

    status 204
  end

  post '/issues' do
    status 503 and return unless @storage

    param :name, String, empty: false
    param :summary, String

    issue = Rack::Newsstand::Issue.new(params)

    if issue.valid?
      directory = @storage.directories.create(key: "newsstand-issue-#{issue.name}-#{Time.now.to_i}", public: true)

      covers, assets = {}, []
      [:covers, :assets].each do |attribute|
        (params[attribute] || []).each do |f|
          file = directory.files.create(
            key: File.basename(f[:filename]),
            body: Base64.decode64(f[:tempfile]),
            public: true
          )

          case attribute
          when :covers
            covers["SOURCE"] = file.public_url
          when :assets
            assets << file.public_url
          end
        end
      end

      cover_urls_string = ""
      covers.each.with_index do |cover, i|
        cover_urls_string << cover.to_s.delete("[]\"\\").gsub(",", "=>")
        cover_urls_string << ',' unless i == cover.count - 1
      end

      asset_urls_string = "{"
      assets.each.with_index do |asset, i|
        asset_urls_string << asset
        asset_urls_string << ',' unless i == assets.count - 1
      end
      asset_urls_string << "}"

      issue.cover_urls = cover_urls_string unless covers.count < 1
      issue.asset_urls = asset_urls_string unless assets.count < 1

      if issue.save
        status 201
        issue.to_json
      else
        status 400
        {errors: issue.errors}.to_json
      end
    else
      status 400
      {errors: issue.errors}.to_json
    end
  end

  template :atom do
<<-EOF
      xml.instruct! :xml, :version => '1.1'
      xml.feed "xmlns" => "http://www.w3.org/2005/Atom",
               "xmlns:news" => "http://itunes.apple.com/2011/Newsstand" do

      xml.updated { @issues.first.updated_at rescue Time.now }

      @issues.each do |issue|
        xml.entry do
          xml.id issue.name
          xml.summary issue.summary
          xml.updated issue.updated_at
          xml.published issue.published_at
          xml.tag!("news:end_date"){ issue.expires_at } if issue.expires_at
          if issue.cover_urls
            xml.tag!("news:cover_art_icons") do
              issue.cover_urls.each do |size, url|
                xml.tag!("news:cover_art_icon", size: size, src: url)
              end
            end
          end
        end
      end
    end
EOF
  end
end
