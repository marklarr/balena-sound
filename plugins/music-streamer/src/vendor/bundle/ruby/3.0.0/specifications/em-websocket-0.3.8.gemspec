# -*- encoding: utf-8 -*-
# stub: em-websocket 0.3.8 ruby lib

Gem::Specification.new do |s|
  s.name = "em-websocket".freeze
  s.version = "0.3.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ilya Grigorik".freeze, "Martyn Loughran".freeze]
  s.date = "2012-07-12"
  s.description = "EventMachine based WebSocket server".freeze
  s.email = ["ilya@igvita.com".freeze, "me@mloughran.com".freeze]
  s.homepage = "http://github.com/igrigorik/em-websocket".freeze
  s.rubygems_version = "3.3.8".freeze
  s.summary = "EventMachine based WebSocket server".freeze

  s.installed_by_version = "3.3.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<eventmachine>.freeze, [">= 0.12.9"])
    s.add_runtime_dependency(%q<addressable>.freeze, [">= 2.1.1"])
    s.add_development_dependency(%q<em-spec>.freeze, ["~> 0.2.6"])
    s.add_development_dependency(%q<eventmachine>.freeze, ["~> 0.12.10"])
    s.add_development_dependency(%q<em-http-request>.freeze, ["~> 0.2.6"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 2.8.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<eventmachine>.freeze, [">= 0.12.9"])
    s.add_dependency(%q<addressable>.freeze, [">= 2.1.1"])
    s.add_dependency(%q<em-spec>.freeze, ["~> 0.2.6"])
    s.add_dependency(%q<eventmachine>.freeze, ["~> 0.12.10"])
    s.add_dependency(%q<em-http-request>.freeze, ["~> 0.2.6"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.8.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
