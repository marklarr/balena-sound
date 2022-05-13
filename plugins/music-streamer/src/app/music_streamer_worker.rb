class MusicStreamerWorker < EM::Connection
  attr_reader :query

  def initialize(*args)
    @app = args.first
    super
  end

  def receive_data(data)
    @currently_playing_pid ||= nil

    # event-machine delivers in batches at each tick
    # Handle multiple messages on a single line
    messages = JSON.parse("[#{data.gsub(/\}.*?\{/m, '},{')}]")

    messages.each { |message| process_message(message) }
  end

  def _init_audio_stream_source_from_msg(message)
    case message["audio_stream_source_type"]
    when 'pandora'
      AudioStreamSource::Pandora.new(message["station_number"])
    when 'youtube'
      AudioStreamSource::Youtube.new(message)
    else
      raise "Unkown audio_stream_source_type in message: #{message}"
    end
  end

  def process_message(message)
    case message['message_type']
    when 'start'
      _do_start(message)
    when 'stop'
      _do_stop(message)
    when 'next_track'
      _do_next_track(message)
    when 'pianobar_eventcmd'
      _do_pianobar_eventcmd(message)
    when 'debug'
      _do_debug(message)
    else
      raise "unknown message_type #{message['message_type']}"
    end
  end

  def _do_start(message)
    _update_status!("Starting...")
    @audio_stream_source&.stop!
    @audio_stream_source = _init_audio_stream_source_from_msg(message)
    _thread { @audio_stream_source.start! }
    _update_status!(@audio_stream_source.name)
  end

  def _do_stop(message)
    _update_status!("Stopping...")
    @audio_stream_source&.stop!
    _update_status!("Stopped.")
    @audio_stream_source = nil
  end

  def _do_next_track(message)
    _update_status!("Skipping...")
    @audio_stream_source&.next_track!
    _update_status!("Skipped")
  end

  def _do_pianobar_eventcmd(message)
    pianobar_event = PianobarEvent.from_parsed_json(JSON.parse(message["event_payload"]))
    _update_status!(pianobar_event.get_status)
    @audio_stream_source.clear_io!
  end

  def _do_debug(message)
    debug_string = @audio_stream_source.get_debug_string
    @app.settings.sockets.each { |s| s.send(debug_string) }
  end

  def _update_status!(status)
    @app.settings.sockets.each { |s| s.send(status) }
    @app.settings.worker_status = status
  end

  def _thread(&block)
    Thread.new(&block)
  end
end

