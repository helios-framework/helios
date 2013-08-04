require 'factory_girl'

FactoryGirl.define do
  factory :newsstand_issue, :class => Rack::Newsstand::Issue do
    name         { generate(:random_string) }
    title        { generate(:random_string) }
    summary      { generate(:random_string) }
    published_at { Date.today }
    to_create    { |instance| instance.save }
  end
end
