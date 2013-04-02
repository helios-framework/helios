command :console do |c|
  c.syntax = 'helios console'
  c.summary = 'Open IRB session with Helios environment'

  c.action do |args, options|
      require 'irb'
      require 'foreman/env'
      require 'sequel'

      @env = {}
      Foreman::Env.new(".env").entries do |name, value|
        @env[name] = value
      end

      Sequel.connect(@env['DATABASE_URL'])

      require 'rack/core-data'
      require 'rack/push-notification'
      require 'rack/in-app-purchase'
      require 'rack/passbook'

      include Rack

      ARGV.clear
      IRB.start
  end
end

alias_command :c, :console
