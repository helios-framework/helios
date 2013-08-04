require 'bundler'
Bundler.require

app = Helios::Application.new do
    service :data, model: Dir['*.xcdatamodel*'].first, only: [:create, :read, :update, :destroy]
    service :push_notification, frontend: false, apn_certificate: 'fake_cert.pem', apn_environment: 'development'
    service :in_app_purchase
    service :passbook
    service :newsstand, storage: ({
      provider:               'AWS',
      aws_access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY']
    } if ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY'])
end

# Customization through composability

# app = Rack::Builder.new do
#   map '/admin' do
#     use Rack::Auth::Basic, "Restricted Area" do |username, password|
#       username == 'admin' and password = "Pa55word"
#     end

#     run Helios::Frontend.new
#   end

#   run Helios::Backend.new {
#     service :data, root: '/', model: Dir['*.xcdatamodel*'].first, only: [:create, :read]
#     service :push_notification
#     service :in_app_purchase
#     service :passbook
#     service :newsstand
#   }
# end

run app
