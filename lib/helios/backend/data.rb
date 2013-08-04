require 'core_data'
require 'sequel'

require 'rack/scaffold'

require 'sinatra/base'
require 'sinatra/param'
require 'rack/contrib'

class Helios::Backend::Data < Sinatra::Base
  helpers Sinatra::Param

  def initialize(app, options = {})
    super(Rack::Scaffold.new(options))

    @model = CoreData::DataModel.new(options[:model]) rescue nil
  end

  before do
    content_type :json
  end

  options '/resources' do

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
