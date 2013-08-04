require 'factory_girl'

FactoryGirl.define do
  factory :passbook_pass, :class => Rack::Passbook::Pass do
    pass_type_identifier { "pass.com.passbook.#{generate(:random_string)}" }
    serial_number        { generate(:random_string) }
    authentication_token { generate(:random_string) }
    created_at           { Date.today }
    updated_at           { Date.today }
    to_create            { |instance| instance.save }
  end
end
