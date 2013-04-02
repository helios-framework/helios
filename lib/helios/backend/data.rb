require 'rack/core-data'
require 'sinatra/param'

class Helios::Backend::Data < Sinatra::Base
  helpers Sinatra::Param

  def initialize(app, options = {})
    super(Rack::CoreData(options[:model]))

    @model = Rack::CoreData::DataModel.new(options[:model])
  end

  before do
    content_type :json
  end

  helpers Sinatra::Param

  options '/' do
    pass unless self.class < Helios::Administerable

    links = []
    @model.entities.each do |entity|
      links << %{</#{entity.name.downcase.pluralize}>; rel="resource"}
    end

    response['Link'] = links.join("\n")

    @model.entities.collect{ |entity|
      {
        name: entity.name,
        url: "/#{entity.name.downcase.pluralize}",
        attributes: Hash[entity.attributes.collect{|attribute| [attribute.name, attribute.type]}]
      }
    }.to_json
  end
end
