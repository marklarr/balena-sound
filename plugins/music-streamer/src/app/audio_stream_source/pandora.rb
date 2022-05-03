class AudioStreamSource
  class Pandora < Base
    STATION = 26 # thumbprint radio TODO: allow as input later

    def start!
      @stdin, @stdout, _stderr, _wait_thr = ShellUtils.popen3("/bin/bash -lc 'pianobar'")
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
  end
end
