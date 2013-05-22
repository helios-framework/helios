require 'dotenv'
require 'sequel'

command :server do |c|
  c.syntax = 'helios server'
  c.summary = 'Start running Helios locally'
  c.option '-w', "--[no-]warn", "Warn about possible database issues"

  c.action do |args, options|
    validate_database_settings! unless options.warn == false

    begin
      exec 'foreman start'
    rescue => exception
      say_error exception.message and abort
    end
  end
end

alias_command :s, :server
alias_command :start, :server
alias_command :launch, :server

private

def validate_database_settings!
  Dotenv.load

  say_error "DATABASE_URL environment variable not set in .env or in Rails config/database.yml" and abort if ENV['DATABASE_URL'].nil?

  uri = URI(ENV['DATABASE_URL'])

  say_error "DATABASE_URL environment variable not set to PostgreSQL database" and abort unless ["postgres", "postgresql"].include?(uri.scheme)

  begin
    db = Sequel.connect(ENV['DATABASE_URL'])
    db.test_connection
  rescue Sequel::DatabaseConnectionError => error
    say_warning %{Error connecting to database: "#{error.message.strip}"}
    case error.message
    when /database "(.+)" does not exist/
      if agree "Would you like to create this database now? (y/n)"
        host, database = uri.host, uri.path.delete("/")

        log 'createdb', database
        system "createdb -h #{host} #{database}"
      end
    else
      abort unless agree "Continue starting Helios? (y/n)"
    end
  end
end
