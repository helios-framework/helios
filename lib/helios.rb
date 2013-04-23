require 'rack'

module Helios
  class Application
    def initialize(app = nil, options = {}, &block)
      map = {}
      map['/'] = Rack::Cascade.new([app, Helios::Backend.new(&block)].compact)
      map['/admin'] = Helios::Frontend.new if options.fetch(:frontend, true)

      @app = Rack::URLMap.new(map)
    end

    def call(env)
      @app.call(env)
    end
  end
end

require 'helios/backend'
require 'helios/frontend'
require 'helios/version'
