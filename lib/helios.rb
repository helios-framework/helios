require 'rack'

module Helios
  class Helios::Application
    def initialize(app = nil, options = {}, &block)
      map = {}
      map['/'] = Helios::Backend.new(&block)
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
