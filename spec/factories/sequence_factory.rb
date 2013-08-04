require 'factory_girl'

FactoryGirl.define do
  sequence(:random_string) {|n| rand(36**8).to_s(36) }
  sequence(:random_token) do |n|
    token = '<'
    5.times do
      token << "%08x" % (rand * 0xffffff) + ' '
    end
    token <<  '>'

    token
  end
  sequence(:random_identifier) { |n| 'pass.com.xyz.' + generate(:random_string) }
  sequence(:random_url) { |n| "http://#{generate(:random_string)}.png" }
end
