class AudioStreamSource
  class Pandora < Base
    STATION = 26 # thumbprint radio TODO: allow as input later

    def start!
      @stdin, @stdout, @stderr, @wait_thr = ShellUtils.popen3("/bin/bash -lc 'pianobar'")
      Timeout::timeout(5) do
        pianobar_output = ""
        until pianobar_output.include?("Select station:") do
          sleep 1
          begin
            pianobar_output += @stdout.read_nonblock(1024 * 10)
          rescue IO::EAGAINWaitReadable => e
          end
        end
      end
      @stdin.puts(STATION)
    end

    def stop!
      ShellUtils.exec("killall pianobar")
    end

    def next_track!
      @stdin.puts("n")
    end

    def name
      "Pandora"
    end

    def get_debug_string
      [
        :stdout => _debug_io(@stdout),
      ].inspect
    end

    def clear_io!
      # Pianobar will stop playing if stdout gets full
      str = _debug_io(@stdout)
      while str.length > 0
        str = _debug_io(@stdout)
      end
    end

    def _debug_io(io)
      begin
        io.read_nonblock(1024 * 10)
      rescue IO::EAGAINWaitReadable => e
        ""
      end
    end
  end
end
