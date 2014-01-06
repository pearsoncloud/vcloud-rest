lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require 'vcloud-rest/version'
Jeweler::Tasks.new do |s|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  s.name = %q{vcloud-rest}
  s.version = VCloudClient::VERSION
  s.authors = ["Stefano Tortarolo", "Gareth Jones"]
  s.email = ['stefano.tortarolo@gmail.com', 'garethmichaeljones@gmail.com']
  s.summary = %q{Unofficial ruby bindings for VMWare vCloud's API}
  s.homepage = %q{https://github.com/astratto/vcloud-rest}
  s.description = %q{Ruby bindings to create, list and manage vCloud servers}
  s.license     = 'Apache 2.0'

  s.require_path = 'lib'
  s.files = ["CHANGELOG.md","README.md", "LICENSE"] + Dir.glob("lib/**/*")
  # dependencies defined in Gemfile
end

require 'rake/testtask'
Rake::TestTask.new(:minitest) do |test|
  test.test_files = FileList["spec/**/*.rb"]
  test.verbose = false
  test.warning = false
end

task :default => [:minitest]