require 'bundler'
Bundler.require

run Helios::Application.new do
        service :data, model: Dir['*.xcdatamodel*'].first
        service :push_notification
        service :in_app_purchase
        service :passbook
    end
