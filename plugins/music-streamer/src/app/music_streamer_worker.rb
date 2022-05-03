class MusicStreamerWorker < EM::Connection
  PULSE_SERVER = ENV["BALENA"] ? "PULSE_SERVER=tcp:localhost:4317" : ""
  puts "pulse server: #{PULSE_SERVER}"

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

  def _thread
    Thread.new(&block)
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

