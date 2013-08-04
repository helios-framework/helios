require 'factory_girl'

FactoryGirl.define do
  factory :user, :class => Rack::Scaffold::Adapters::CoreData::User do
    name      'bob'
    email     'bob@tester.com'
    to_create { |instance| instance.save }
  end
end
