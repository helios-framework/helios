require 'rack'

module Helios
  class Backend < Rack::Cascade
    require 'rails-database-url' if const_defined?(:Rails)

    def initialize(&block)
      raise ArgumentError, "Missing block" unless block_given?

      @services = []

      instance_eval(&block)

      super(@services)
    end

    private

    def service(identifier, options = {}, &block)
      if identifier.is_a?(Class)
        middleware = identifier
      else
        begin
          middleware = Helios::Backend.const_get(constantize(identifier))
        rescue NameError
          raise LoadError, "Could not find matching service for #{identifier.inspect} (Helios::Backend::#{constantize(identifier)}). You may need to install an additional gem (such as helios-#{identifier})."
        end
      end

      middleware.instance_eval{ include Helios::Administerable } if options.fetch(:frontend, true)

      @services << middleware.new(self, options, &block) if middleware
    end

    def constantize(identifier)
      identifier.to_s.split(/([[:alpha:]]*)/).select{|c| /[[:alpha:]]/ === c}.map(&:capitalize).join("")
    end
  end

  module Administerable
    attr_accessor :admin

    def admin?
      !!@admin
    end
  end
end

require 'helios/backend/data'
require 'helios/backend/in-app-purchase'
require 'helios/backend/newsstand'
require 'helios/backend/passbook'
require 'helios/backend/push-notification'
