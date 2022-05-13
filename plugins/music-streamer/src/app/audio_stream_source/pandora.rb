class AudioStreamSource
  class Pandora < Base
    def initialize(station_number)
      @station_number = station_number
    end

    def start!
      _launch_pianobar do |stdin, stdout, stderr, wait_thr, _initial_stdout_string|
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @wait_thr = wait_thr
        @stdin.puts(@station_number)
      end
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
      return unless @stdout
      # Pianobar will stop playing if stdout gets full
      str = _debug_io(@stdout)
      while str.length > 0
        str = _debug_io(@stdout)
      end
    end

    def get_station_list
      result = _launch_pianobar do |stdin, stdout, stderr, wait_thr, initial_stdout_string|
        initial_stdout_string.split("\n").each_with_object({}) do |line, station_acc_hash|
          station_number, station_name = line.scan(/\s*(\d+)\)\s+q\s+(.+)/i).first
          station_acc_hash[station_number] = station_name if station_number && station_name
          station_acc_hash
        end
      end
      stop!
      result
    end

    def _launch_pianobar
      stdin, stdout, stderr, wait_thr = ShellUtils.popen3("/bin/bash -lc 'pianobar'")
      pianobar_output = ""
      Timeout::timeout(5) do
        until pianobar_output.include?("Select station:") do
          sleep 1
          begin
            pianobar_output += stdout.read_nonblock(1024 * 10)
          rescue IO::EAGAINWaitReadable => e
          end
        end
      end
      yield stdin, stdout, stderr, wait_thr, pianobar_output
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
