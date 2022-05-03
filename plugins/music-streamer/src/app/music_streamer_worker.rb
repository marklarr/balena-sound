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
      AudioStreamSource::Pandora.new(message)
    when 'youtube'
      AudioStreamSource::Youtube.new(message)
    else
      raise "Unkown audio_stream_source_type in message: #{message}"
    end
  end

  def process_message(message)
    case message['message_type']
    when 'start'
      _update_status!("Starting...")
      @audio_stream_source&.stop!
      @audio_stream_source = _init_audio_stream_source_from_msg(message)
      _thread { @audio_stream_source.start! }
      _update_status!(@audio_stream_source.name)
    when 'stop'
      _update_status!("Stopping...")
      @audio_stream_source&.stop!
      _update_status!("Stopped.")
      @audio_stream_source = nil
    when 'next_track'
      _update_status!("Skipping...")
      @audio_stream_source&.next_track!
      _update_status!("Skipped")
    when 'pianobar_eventcmd'
      pianobar_event = PianobarEvent.from_parsed_json(JSON.parse(message["event_payload"]))
      _update_status!(pianobar_event.get_status)
    else
      raise "unknown message_type #{message['message_type']}"
    end
  end

  def _update_status!(status)
    @app.settings.sockets.each { |s| puts s.send(status) }
    @app.settings.worker_status = status
  end

  def _thread(&block)
    Thread.new(&block)
  end
end

