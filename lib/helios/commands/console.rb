command :console do |c|
  c.syntax = 'helios console'
  c.summary = 'Open IRB session with Helios environment'

  c.action do |args, options|
      require 'irb'
      require 'dotenv'
      require 'sequel'
      require 'helios'

      include Rack

      Dotenv.load
      Sequel.connect(ENV['DATABASE_URL'])

      Rack::Scaffold.new(models: Dir['*.xcdatamodel*'])
      Rack::Scaffold::Adapters::CoreData.constants.each do |constant|
        Data.const_set(constant, Rack::Scaffold::Adapters::CoreData.const_get(constant))
      end

      ARGV.clear
      IRB.start
  end
end

alias_command :c, :console
