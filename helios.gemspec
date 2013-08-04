# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "helios/version"

Gem::Specification.new do |s|
  s.name        = "helios"
  s.authors     = ["Mattt Thompson"]
  s.email       = "mattt@heroku.com"
  s.license     = "MIT"
  s.homepage    = "http://helios.io"
  s.version     = Helios::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "An extensible open-source mobile backend framework"
  s.description = "Helios is an open-source framework that provides essential backend services for iOS apps, from data synchronization and user accounts to push notifications, in-app purchases, and passbook integration. It allows developers to get a client-server app up-and-running in just a few minutes, and seamlessly incorporate functionality as necessary."

  s.add_dependency "commander", "~> 4.1"
  s.add_dependency "foreman", "~> 0.63"
  s.add_dependency "rack-contrib", "~> 1.1"
  s.add_dependency "rack-push-notification", "~> 0.4"
  s.add_dependency "rack-in-app-purchase", "~> 0.1"
  s.add_dependency "rack-passbook", "~> 0.1"
  s.add_dependency "rack-newsstand", "~> 0.1"
  s.add_dependency "rack-scaffold", ">= 0.0.3"
  s.add_dependency "core_data"
  s.add_dependency "json", "~> 1.7"
  s.add_dependency "coffee-script", "~> 2.2"
  s.add_dependency "sinatra", "~> 1.3"
  s.add_dependency "sinatra-contrib", "~> 1.3"
  s.add_dependency "sinatra-assetpack", "0.2.3"
  s.add_dependency "sinatra-backbone", "~> 0.1.1"
  s.add_dependency "sinatra-param", "~> 0.1"
  s.add_dependency "sinatra-support", "~> 1.2"
  s.add_dependency "haml", ">= 3.1"
  s.add_dependency "compass", "~> 0.12"
  s.add_dependency "zurb-foundation", "4.1.2"
  s.add_dependency "rails-database-url", "~> 1.0"
  s.add_dependency "fog", "~> 1.10"
  s.add_dependency "houston", "~> 0.2"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pg"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "pry-debugger"
  s.add_development_dependency "pry"
  s.add_development_dependency "json_spec"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "guard"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "guard-bundler"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "simplecov"

  s.files         = Dir["./**/*"].reject{|file| file =~ /\.\/(bin|example|log|pkg|script|spec|test|vendor)/} + Dir.glob("./lib/helios/templates/*", File::FNM_DOTMATCH)
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
