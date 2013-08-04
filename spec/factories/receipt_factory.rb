require 'factory_girl'

FactoryGirl.define do
  factory :inapp_receipt, :class => Rack::InAppPurchase::Receipt do
    quantity                    1
    product_id                  'com.xyz.inapp.product'
    transaction_id              { generate(:random_string) }
    purchase_date               { Date.today }
    original_transaction_id     { generate(:random_string) }
    original_purchase_date      { Date.today }
    app_item_id                 'com.xyz.inapp.product'
    version_external_identifier 'com.xyz.inapp.product'
    bid                         { generate(:random_string) }
    bvrs                        { generate(:random_string) }
    ip_address                  '127.0.0.1'
    created_at                  { Date.today.prev_day }
    to_create                   { |instance| instance.save }
  end
end
