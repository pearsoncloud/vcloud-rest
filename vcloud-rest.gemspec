# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: vcloud-rest 1.7.4 ruby lib

Gem::Specification.new do |s|
  s.name = "vcloud-rest"
  s.version = "1.7.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stefano Tortarolo", "Gareth Jones"]
  s.date = "2014-05-02"
  s.description = "Ruby bindings to create, list and manage vCloud servers"
  s.email = ["stefano.tortarolo@gmail.com", "gareth.jones@pearson.com"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "CHANGELOG.md",
    "LICENSE",
    "README.md",
    "lib/vcloud-rest/connection.rb",
    "lib/vcloud-rest/vcloud/catalog.rb",
    "lib/vcloud-rest/vcloud/edgegateway.rb",
    "lib/vcloud-rest/vcloud/network.rb",
    "lib/vcloud-rest/vcloud/org.rb",
    "lib/vcloud-rest/vcloud/ovf.rb",
    "lib/vcloud-rest/vcloud/vapp.rb",
    "lib/vcloud-rest/vcloud/vapp_networking.rb",
    "lib/vcloud-rest/vcloud/vdc.rb",
    "lib/vcloud-rest/vcloud/vm.rb",
    "lib/vcloud-rest/version.rb"
  ]
  s.homepage = "https://github.com/pearsoncloud/vcloud-rest"
  s.licenses = ["Apache 2.0"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.11"
  s.summary = "Unofficial ruby bindings for VMWare vCloud's API"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.5.10"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_runtime_dependency(%q<httpclient>, ["~> 2.3.3"])
      s.add_runtime_dependency(%q<ruby-progressbar>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<awesome_print>, ["~> 1.2.0"])
      s.add_development_dependency(%q<vcloud-rest>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.5.10"])
      s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_dependency(%q<httpclient>, ["~> 2.3.3"])
      s.add_dependency(%q<ruby-progressbar>, ["~> 1.2.0"])
      s.add_dependency(%q<awesome_print>, ["~> 1.2.0"])
      s.add_dependency(%q<vcloud-rest>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.5.10"])
    s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
    s.add_dependency(%q<httpclient>, ["~> 2.3.3"])
    s.add_dependency(%q<ruby-progressbar>, ["~> 1.2.0"])
    s.add_dependency(%q<awesome_print>, ["~> 1.2.0"])
    s.add_dependency(%q<vcloud-rest>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end

