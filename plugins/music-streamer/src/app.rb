require 'rack'
require 'sinatra/base'
require 'sinatra-websocket'
require 'eventmachine'
require 'json'
require 'sys/proctable'
require 'open3'
require "uri"
require "net/http"
require 'logger'
require "require_all"
require_all "app/"

PULSE_SERVER = ENV["BALENA"] ? "PULSE_SERVER=tcp:localhost:4317" : ""
puts "pulse server: #{PULSE_SERVER}"

unless Sinatra::Application.environment == :test
  EM::run do
    MusicStreamerApplication.run!
  end
end

