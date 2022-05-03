class MusicStreamerApplication < Sinatra::Base
  MAX_VOLUME = 100
  MIN_VOLUME = 0

  use Rack::CommonLogger
  use EventMachineMiddleWare

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
    EventMachine::start_server '127.0.0.1', '4000', MusicStreamerWorker, self
    super
  end

  helpers do
    def event_machine_server; env['event_machine_server']; end
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
    event_machine_server.send_data({:message_type => "start", :audio_stream_source_type => 'youtube'}.to_json)
    201
  end

  post '/stream/pandora_radio' do
    event_machine_server.send_data({:message_type => "start", :audio_stream_source_type => 'pandora'}.to_json)
    201
  end

  post '/stream/next_track' do
    event_machine_server.send_data({:message_type => "next_track"}.to_json)
    201
  end

  post '/stream/stop' do
    event_machine_server.send_data({:message_type => "stop"}.to_json)
    201
  end

  post '/pianobar_eventcmd' do
    request_body = request.body.read.force_encoding("utf-8")
    event_machine_server.send_data({:message_type => "pianobar_eventcmd", :event_payload => request_body}.to_json)
    201
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

