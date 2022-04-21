require 'rack'
require 'sinatra/base'
require 'eventmachine'
require 'json'

class Worker < EM::Connection
  attr_reader :query

  def receive_data(data)
    @currently_playing_pid ||= nil
    message =  JSON::parse(data)

    case message['action']
    when 'lofi_hip_hop_radio'
      _stop
      _play_lofi_radio
    when 'stop'
      _stop
    else
      raise "unknown action #{message['action']}"
    end
  end

  private

	def _play_lofi_radio
    Thread.new do
      # TODO: env var
      @currently_playing_pid = Process.spawn("PULSE_SERVER=tcp:localhost:4317 ffplay -nodisp <(youtube-dl -f 96  'https://www.youtube.com/watch?v=5qap5aO4i9A' -o -) 2> /dev/null")
      Process.wait(@currently_playing_pid)
    end
	end

  def _stop
    if @currently_playing_pid
      `pkill -P #{@currently_playing_pid}`
      Process.kill(:SIGKILL, @currently_playing_pid)
      @currently_playing_pid = nil
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
