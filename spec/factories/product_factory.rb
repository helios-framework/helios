require 'factory_girl'

FactoryGirl.define do
  factory :product, :class => Rack::Scaffold::Adapters::CoreData::Product do
    name      'cool product'
    price     1.20
    quantity  100
    to_create { |instance| instance.save }
  end

  factory :invalid_product, :class => Rack::Scaffold::Adapters::CoreData::Product do
    name      'invalid product'
    to_create { |instance| instance.save }
  end
end
