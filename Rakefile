require "bundler"
Bundler.setup

gemspec = eval(File.read("helios.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["helios.gemspec"] do
  system "gem build helios.gemspec"
  system "gem install helios-#{Helios::VERSION}.gem"
end
