#!/usr/bin/ruby

require "json"
require "uri"
require "net/http"

event = ARGV.first

data = {}
STDIN.each_line { |line| data.store(*line.chomp.split("=", 2)) }

data[:event_type] = event


http = Net::HTTP.new("localhost", 3434)

request = Net::HTTP::Post.new("/pianobar_eventcmd")
request.body = data.to_json
_response = http.request(request)
