# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "netid-tools"
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nikky Southerland"]
  s.date = "2013-06-28"
  s.description = "Gem with various methods to support UW NetIDs"
  s.email = "nikky@uw.edu"
  s.executables = ["ua_check"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/ua_check",
    "lib/generic-response.rb",
    "lib/netid-tools.rb",
    "lib/netid-validator.rb",
    "lib/quota-response.rb",
    "lib/system-connect.rb",
    "lib/unix-processes.rb",
    "netid-tools.gemspec",
    "spec/netid_tools_spec.rb",
    "spec/spec_helper.rb",
    "spec/unix_processes_spec.rb"
  ]
  s.homepage = "http://github.com/allynfolksjr/netid-tools"
  s.licenses = ["Apache License, Version 2.0"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Gem with various methods to support UW NetIDs"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<colored>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<terminal-table>, [">= 0"])
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<colored>, [">= 0"])
    else
      s.add_dependency(%q<colored>, [">= 0"])
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<terminal-table>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<colored>, [">= 0"])
    end
  else
    s.add_dependency(%q<colored>, [">= 0"])
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<terminal-table>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<colored>, [">= 0"])
  end
end

