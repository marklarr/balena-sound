# -*- encoding: utf-8 -*-
# stub: sinatra-websocket 0.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sinatra-websocket".freeze
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Caleb Crane".freeze]
  s.date = "2014-12-02"
  s.description = "Makes it easy to upgrade any request to a websocket connection in Sinatra".freeze
  s.email = "sinatra-websocket@simulacre.org".freeze
  s.homepage = "http://github.com/simulacre/sinatra-websocket".freeze
  s.rubygems_version = "3.3.8".freeze
  s.summary = "Simple, upgradable WebSockets for Sinatra.".freeze

  s.installed_by_version = "3.3.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<eventmachine>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<thin>.freeze, [">= 1.3.1", "< 2.0.0"])
    s.add_runtime_dependency(%q<em-websocket>.freeze, ["~> 0.3.6"])
  else
    s.add_dependency(%q<eventmachine>.freeze, [">= 0"])
    s.add_dependency(%q<thin>.freeze, [">= 1.3.1", "< 2.0.0"])
    s.add_dependency(%q<em-websocket>.freeze, ["~> 0.3.6"])
  end
end
