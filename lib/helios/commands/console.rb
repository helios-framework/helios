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

      ARGV.clear
      IRB.start
  end
end

alias_command :c, :console
