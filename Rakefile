require "bundler"
Bundler.setup

## Gem Tasks
gemspec = eval(File.read("helios.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["helios.gemspec"] do
  system "gem build helios.gemspec"
end

## Test Tasks
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task :default => :spec
