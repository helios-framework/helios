ENV['RACK_ENV'] = 'test'
ENV['HELIOS_ADMIN_USERNAME'] = 'admin'
ENV['HELIOS_ADMIN_PASSWORD'] = 'password'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require_relative '../lib/helios.rb'
require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rack/test'
require 'pry'
require 'json_spec'
require 'factory_girl'
require 'database_cleaner'
require 'base64'

def db_uri
  "postgres://localhost/test_helios"
end

def app
  Helios::Application.new do
      service :data, model: Dir['example/*.xcdatamodel*'].first, only: [:create, :read, :destroy, :update]
      service :push_notification, frontend: false, apn_certificate: 'example/fake_cert.pem', apn_environment: 'development'
      service :in_app_purchase
      service :passbook
      service :newsstand, :storage => {
        provider:               'AWS',
        aws_access_key_id:      'THISISNTREALBUTITWILLWORK',
        aws_secret_access_key:  'TOTALLYFAKEBUTTHISWILLALSOWORKAWESOME',
      }
  end
end

def last_json
  last_response.body
end

def json_hash
  JSON.parse(last_json)
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include JsonSpec::Helpers
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DB = Sequel.connect(db_uri)
    options = { model: Dir['example/*.xcdatamodel*'].first, only: [:create, :read, :destroy, :update] }
    backend = Helios::Backend::Data.new(nil, options)
    DatabaseCleaner[:sequel].strategy = :truncation, {:pre_count => true}
    DatabaseCleaner[:sequel].clean_with(:truncation)
    Dir[File.dirname(__FILE__)+"/factories/*_factory.rb"].each {|file| require file }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    %w(users products push_notification_devices in_app_purchase_receipts in_app_purchase_products newsstand_issues passbook_passes passbook_registrations).each do |table|
      DB.reset_primary_key_sequence(table.to_sym)
    end
  end
end
