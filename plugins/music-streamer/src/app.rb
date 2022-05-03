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

# TODO:
# youtube-dl --get-thumbnail 'https://www.youtube.com/watch?v=5qap5aO4i9A'

# TODO: find a way to skip this in full-stack tests
# EM::run do
#   MusicStreamerApplication.run!
# end

