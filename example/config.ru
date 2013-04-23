require 'bundler'
Bundler.require

run Helios::Application.new nil, frontend_root: '/admin', backend_root: '/' do
        service :data, model: Dir['*.xcdatamodel*'].first
        service :push_notification
        service :in_app_purchase
        service :passbook
    end
