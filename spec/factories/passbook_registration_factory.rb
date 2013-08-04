require 'factory_girl'

FactoryGirl.define do
  factory :passbook_registration, :class => Rack::Passbook::Registration do
    device_library_identifier { generate(:random_string) }
    push_token                { generate(:random_token) }
    pass_id                   { create(:passbook_pass).id }
    created_at                { Date.today }
    updated_at                { Date.today }
    to_create                 { |instance| instance.save }
  end
end
