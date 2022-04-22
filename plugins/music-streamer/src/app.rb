require 'rack'
require 'sinatra/base'
require 'eventmachine'
require 'json'
require 'sys/proctable'

PULSE_SERVER = ENV["BALENA"] ? "PULSE_SERVER=tcp:localhost:4317" : ""
puts "pulse server: #{PULSE_SERVER}"

class Worker < EM::Connection
  attr_reader :query

  def receive_data(data)
    @currently_playing_pid ||= nil
    messages = JSON.parse("[#{data.gsub(/\}.*?\{/m, '},{')}]")
    messages.each { |message| process_message(message) }
  end

  def process_message(message)
    case message['action']
    when 'lofi_hip_hop_radio'
      # don't play if already playing; no-op instead
      puts "playing lofi_hip_hop_radio"
      _stop
      _play_lofi_radio
    when 'stop'
      puts "stopping"
      _stop
    else
      raise "unknown action #{message['action']}"
    end
  end

  private

  def _play_lofi_radio
    Thread.new do
      # TODO: env var
      @currently_playing_pid = Process.spawn("/bin/bash -c \"#{PULSE_SERVER} ffplay -nodisp <(youtube-dl -f 96  'https://www.youtube.com/watch?v=5qap5aO4i9A' -o -) 2> /dev/null\"")
      Process.wait(@currently_playing_pid)
    end
  end

  def _stop
    `killall ffplay`
    # if @currently_playing_pid
    #   all_pids_to_kill = _recurse_child_pids(@currently_playing_pid)
    #   all_pids_to_kill << @currently_playing_pid
    #   all_pids_to_kill.sort.reverse.each do |pid_to_kill|
    #     `kill -9 #{pid_to_kill}`
    #   end
    #   @currently_playing_pid = nil
    # end
  end

  def _recurse_child_pids(parent_pid)
    child_pids = Sys::ProcTable.ps.select { |pe| pe.ppid == parent_pid }.map(&:pid)
    child_pids.each_with_object(child_pids.dup) do |child_pid, acc|
      acc.concat(_recurse_child_pids(child_pid))
    end
  end
end

class Broker

  def initialize(app, options = {})
    @app = app
    puts "B: Starting broker"
    EM::next_tick do
      @server = EM::connect('127.0.0.1', 4000, Worker, self)
    end
  end

  def call(env)
    env['broker'] = @server
    @app.call(env)
  end

end

class App < Sinatra::Base

  use Rack::CommonLogger
  use Broker

  set server: 'thin'

  set port: 3434
  enable :xhtml
  enable :dump_errors
  enable :show_errors
  enable :show_exceptions

  helpers do
    def broker; env['broker']; end
  end

  post '/play/lofi_hip_hop_radio' do
    broker.send_data({:action => "lofi_hip_hop_radio"}.to_json)
    201
  end

  post '/stop' do
    broker.send_data({:action => "stop"}.to_json)
    201
  end

end

EM::run {
  EventMachine::start_server '127.0.0.1', '4000', Worker
  App.run!
}
