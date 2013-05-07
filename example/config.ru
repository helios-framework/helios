require 'bundler'
Bundler.require

app = Helios::Application.new do
    service :data, model: Dir['*.xcdatamodel*'].first, only: [:create, :read]
    service :push_notification
    service :in_app_purchase
    service :passbook
    service :newsstand, storage: {
      provider:               'AWS',
      aws_access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY']
    } if ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
end

run app