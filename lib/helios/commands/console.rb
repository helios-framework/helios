command :console do |c|
  c.syntax = 'helios console'
  c.summary = 'Open IRB session with Helios environment'

  c.action do |args, options|
      require 'irb'
      require 'dotenv'
      require 'sequel'

      @env = {}
      @env.update Dotenv::Environment.new(".env")

      Sequel.connect(@env['DATABASE_URL'])

      require 'rack/scaffold'
      require 'rack/push-notification'
      require 'rack/in-app-purchase'
      require 'rack/passbook'
      require 'rack/newsstand'

      include Rack

      ARGV.clear
      IRB.start
  end
end

alias_command :c, :console
