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

# TODO:
# youtube-dl --get-thumbnail 'https://www.youtube.com/watch?v=5qap5aO4i9A'

# artist"=>"TOOL",
#  "title"=>"Jimmy",
#  "album"=>"Ænima (Explicit)",
#  "coverArt"=>
#   "http://cont-3.p-cdn.us/images/51/2f/74/6f/ac5a47fe8eeb1d2ef56cb9e1/1080W_1080H.jpg",
#  "stationName"=>"TOOL Radio",
#  "songStationName"=>"",
#  "pRet"=>"1",
#  "pRetStr"=>"Everything is fine :)",
#  "wRet"=>"0",
#  "wRetStr"=>"No error",
#  "songDuration"=>"324",
#  "songPlayed"=>"10",
#  "rating"=>"0",
#  "detailUrl"=>
#   "http://www.pandora.com/tool/nima-explicit/jimmy/TRzxmp4nljn7mrV?dc=1777&ad=0:30:1:55455::0:0:0:1:613:027:MN:27053:2:0:0:0:2996:0",
#  "stationCount"=>"29",
#  "station0"=>"90s Alternative  Radio",
#  "station1"=>"A Perfect Circle Radio",
#  "station2"=>"Alternative Rock Radio",
#  "station3"=>"Ambient Radio",
#  "station4"=>"Blonde Redhead Radio",
#  "station5"=>"Bush Radio",
#  "station6"=>"Chill Out Radio",
#  "station7"=>"Classical for Work Radio",
#  "station8"=>"Filter Radio",
#  "station9"=>"Gold Guns Girls Radio",
#  "station10"=>"Liars Radio",
#  "station11"=>"Marilyn Manson Radio",
#  "station12"=>"Meditation Radio",
#  "station13"=>"Modest Mouse Radio",
#  "station14"=>"New Chill Radio",
#  "station15"=>"Nine Inch Nails Radio",
#  "station16"=>"No Doubt Radio",
#  "station17"=>"Placebo Radio",
#  "station18"=>"QuickMix",
#  "station19"=>"Radiohead Radio",
#  "station20"=>"RJD2 Radio",
#  "station21"=>"Silversun Pickups Radio",
#  "station22"=>"Smashing Pumpkins Radio",
#  "station23"=>"Soundgarden Radio",
#  "station24"=>"The Mars Volta Radio",
#  "station25"=>"Third Eye Blind Radio",
#  "station26"=>"Thumbprint Radio",
#  "station27"=>"TOOL Radio",
#  "station28"=>"Ween Radio",
#  "event_type"=>"songfinish"}
# ::1 - - [28/Apr/2022:14:23:53 -0700] "POST /pianobar_eventcmd HTTP/1.1" 200 - 0.0015
# {"artist"=>"A Perfect Circle",
#  "title"=>"Magdalena",
#  "album"=>"Mer De Noms (Explicit)",
#  "coverArt"=>
#   "http://cont-5.p-cdn.us/images/09/dc/98/33/d8fa4c3883c678630752ba9e/1080W_1080H.jpg",
#  "stationName"=>"TOOL Radio",
#  "songStationName"=>"",
#  "pRet"=>"1",
#  "pRetStr"=>"Everything is fine :)",
#  "wRet"=>"0",
#  "wRetStr"=>"No error",
#  "songDuration"=>"246",
#  "songPlayed"=>"0",
#  "rating"=>"0",
#  "detailUrl"=>
#   "http://www.pandora.com/perfect-circle/mer-de-noms-explicit/magdalena/TRVgXpg6rdqvhd4?dc=1777&ad=0:30:1:55455::0:0:0:1:613:027:MN:27053:2:0:0:0:2996:0",
#  "stationCount"=>"29",
#  "station0"=>"90s Alternative  Radio",
#  "station1"=>"A Perfect Circle Radio",
#  "station2"=>"Alternative Rock Radio",
#  "station3"=>"Ambient Radio",
#  "station4"=>"Blonde Redhead Radio",
#  "station5"=>"Bush Radio",
#  "station6"=>"Chill Out Radio",
#  "station7"=>"Classical for Work Radio",
#  "station8"=>"Filter Radio",
#  "station9"=>"Gold Guns Girls Radio",
#  "station10"=>"Liars Radio",
#  "station11"=>"Marilyn Manson Radio",
#  "station12"=>"Meditation Radio",
#  "station13"=>"Modest Mouse Radio",
#  "station14"=>"New Chill Radio",
#  "station15"=>"Nine Inch Nails Radio",
#  "station16"=>"No Doubt Radio",
#  "station17"=>"Placebo Radio",
#  "station18"=>"QuickMix",
#  "station19"=>"Radiohead Radio",
#  "station20"=>"RJD2 Radio",
#  "station21"=>"Silversun Pickups Radio",
#  "station22"=>"Smashing Pumpkins Radio",
#  "station23"=>"Soundgarden Radio",
#  "station24"=>"The Mars Volta Radio",
#  "station25"=>"Third Eye Blind Radio",
#  "station26"=>"Thumbprint Radio",
#  "station27"=>"TOOL Radio",
#  "station28"=>"Ween Radio",
#  "event_type"=>"songstart"}

PULSE_SERVER = ENV["BALENA"] ? "PULSE_SERVER=tcp:localhost:4317" : ""
puts "pulse server: #{PULSE_SERVER}"

MAX_VOLUME = 100
MIN_VOLUME = 0

module ShellUtils
  def self.spawn(*args)
    Process.spawn(*args)
  end

  def self.wait(*args)
    Process.wait(*args)
  end

  def self.exec(cmd)
    `#{cmd}`
  end

  def self.popen3(*args)
    Open3.popen3(*args)
  end
end

module SnapcastGateway
  def self.http_post(body)
    http = Net::HTTP.new("192.168.0.23", 1780)

    request = Net::HTTP::Post.new("/jsonrpc")
    request.body = body
    response = http.request(request)
    JSON.parse(response.read_body)
  end

  def self.get_status(client_id)
    body = %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"#{client_id}"}})
    http_post(body)
  end

  def self.set_volume_percent(client_id, volume_percent)
    body = %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"#{client_id}","volume":{"muted":false, "percent":#{volume_percent}}}})
    http_post(body)
  end

  def self.set_volume_muted(client_id, muted)
    body = %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"#{client_id}","volume":{"muted":#{muted}}}})
    http_post(body)
  end
end

class Worker < EM::Connection
  attr_reader :query

  def initialize(*args)
    @app = args.first
    super
  end

  def receive_data(data)
    @currently_playing_pid ||= nil
    messages = JSON.parse("[#{data.gsub(/\}.*?\{/m, '},{')}]")
    messages.each { |message| process_message(message) }
  end

  def process_message(message)
    puts "[#{self.class}] message received: #{message}"
    _update_status!(message['action'])
    case message['action']
    when 'stream_youtube'
      # TODO: don't play if already playing; no-op instead
      _stop
      _play_lofi_radio
    when 'stream_pandora_radio'
      _stop
      _play_pandora_radio
    when 'stop'
      puts "stopping"
      _stop
    else
      raise "unknown action #{message['action']}"
    end
  end

  def _update_status!(status)
    @app.settings.sockets.each { |s| puts s.send(status) }
    @app.settings.worker_status = status
  end

  def _play_lofi_radio
    _thread do
      # TODO: env var
      @currently_playing_pid = ShellUtils.spawn("/bin/bash -c \"#{PULSE_SERVER} ffplay -nodisp <(youtube-dl -f 96  'https://www.youtube.com/watch?v=5qap5aO4i9A' -o -) 2> /dev/null\"")
      _update_status!("Playing Lofi")
      ShellUtils.wait(@currently_playing_pid)
    end

    def _thread
      Thread.new(&block)
    end
  end

  STATION = 26 # thumbprint radio TODO: allow as input later
  def _play_pandora_radio
    _thread do
      stdin, stdout, stderr, wait_thr = ShellUtils.popen3("/bin/bash -lc 'pianobar'")
      Timeout::timeout(5) do
        pianobar_output = ""
        until pianobar_output.include?("Select station:") do
          sleep 1
          begin
            pianobar_output += stdout.read_nonblock(1024 * 10)
          rescue IO::EAGAINWaitReadable => e
          end
        end
      end
      stdin.puts(STATION)
      _update_status!("Playing Pandora")
    end
  end

  def _stop
    ShellUtils.exec("killall ffplay")
    ShellUtils.exec("killall pianobar")
    _update_status!("Stopped.")
    # if @currently_playing_pid
    #   all_pids_to_kill = _recurse_child_pids(@currently_playing_pid)
    #   all_pids_to_kill << @currently_playing_pid
    #   all_pids_to_kill.sort.reverse.each do |pid_to_kill|
    #     ShellUtils.exec("kill -9 #{pid_to_kill}")
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

class MusicStreamerApplication < Sinatra::Base
  use Rack::CommonLogger
  use Broker

  set server: 'thin'

  set port: 3434
  set sockets: []
  set worker_status: ""
  enable :xhtml
  enable :dump_errors
  enable :show_errors
  enable :show_exceptions

  configure :test do
    set :raise_errors, true
    set :dump_errors, false
    set :show_exceptions, false
  end


  def initialize(*args)
    EventMachine::start_server '127.0.0.1', '4000', Worker, self
    super
  end

  helpers do
    def broker; env['broker']; end
  end


  get '/websocket/updates' do
    if request.websocket?
      request.websocket do |ws|
        ws.onopen do
          ws.send(settings.worker_status)
          settings.sockets << ws
        end

        ws.onclose do
          settings.sockets.delete(ws)
        end
      end
    else
      404
    end
  end

  post '/stream/youtube' do
    broker.send_data({:action => "stream_youtube"}.to_json)
    201
  end

  post '/stream/pandora_radio' do
    broker.send_data({:action => "stream_pandora_radio"}.to_json)
    201
  end

  post '/stream/stop' do
    broker.send_data({:action => "stop"}.to_json)
    201
  end

  post '/pianobar_eventcmd' do
    request_body = JSON.parse(request.body.read)
    require 'pp'
    pp request_body
  end

  post '/snapcast/:client_id/toggle_mute' do
    response_body_parsed = SnapcastGateway.get_status(params[:client_id])

    current_mute_status = response_body_parsed["result"]["client"]["config"]["volume"]["muted"]
    new_mute_status = !current_mute_status

    SnapcastGateway.set_volume_muted(params[:client_id], new_mute_status)
    201
  end

  post '/snapcast/:client_id/volume_up' do
    response_body_parsed = SnapcastGateway.get_status(params[:client_id])

    current_volume = response_body_parsed["result"]["client"]["config"]["volume"]["percent"]
    new_volume = [current_volume + 5, MAX_VOLUME].min

    SnapcastGateway.set_volume_percent(params[:client_id], new_volume)
    201
  end

  post '/snapcast/:client_id/volume_down' do
    response_body_parsed = SnapcastGateway.get_status(params[:client_id])

    current_volume = response_body_parsed["result"]["client"]["config"]["volume"]["percent"]
    new_volume = [current_volume - 5, MIN_VOLUME].max

    SnapcastGateway.set_volume_percent(params[:client_id], new_volume)
    201
  end
end

# EM::run do
#   MusicStreamerApplication.run!
# end

