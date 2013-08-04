require 'factory_girl'

FactoryGirl.define do
  factory :inapp_product, :class => Rack::InAppPurchase::Product do
    product_identifier 'com.xyz.inapp.product'
    type               'Consumable'
    title              'new hotness'
    description        'foo\'s your bar with baz'
    price              0.99
    price_locale       'US'
    is_enabled         true
    to_create          { |instance| instance.save }
  end
end
