require 'rack'

module Helios
  class Application
    def initialize(app = nil, options = {}, &block)
      @app = Rack::Builder.new do
        map '/admin' do
          use Rack::Auth::Basic, "Restricted Area" do |username, password|
            username == (ENV['HELIOS_ADMIN_USERNAME'] || "") and password == (ENV['HELIOS_ADMIN_PASSWORD'] || "")
          end if ENV['HELIOS_ADMIN_USERNAME'] or ENV['HELIOS_ADMIN_PASSWORD']

          run Helios::Frontend.new
        end

        run Rack::Cascade.new([app, Helios::Backend.new(&block)].compact)
      end
    end

    def call(env)
      @app.call(env)
    end
  end
end

require 'helios/backend'
require 'helios/frontend'
require 'helios/version'
