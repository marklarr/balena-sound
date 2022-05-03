# TODO:
# youtube-dl --get-thumbnail 'https://www.youtube.com/watch?v=5qap5aO4i9A'
#
class AudioStreamSource
  class Youtube < Base
    def initialize(src_url)
      @src_url = src_url
    end

    def start!
      @currently_playing_pid = ShellUtils.spawn("/bin/bash -c \"#{PULSE_SERVER} ffplay -nodisp <(youtube-dl -f 96  'https://www.youtube.com/watch?v=5qap5aO4i9A' -o -) 2> /dev/null\"")
      ShellUtils.wait(@currently_playing_pid)
    end

    def stop!
      ShellUtils.exec("killall ffplay")
    end
    # if @currently_playing_pid
    #   all_pids_to_kill = _recurse_child_pids(@currently_playing_pid)
    #   all_pids_to_kill << @currently_playing_pid
    #   all_pids_to_kill.sort.reverse.each do |pid_to_kill|
    #     ShellUtils.exec("kill -9 #{pid_to_kill}")
    #   end
    #   @currently_playing_pid = nil
    # end
  # def _recurse_child_pids(parent_pid)
  #   child_pids = Sys::ProcTable.ps.select { |pe| pe.ppid == parent_pid }.map(&:pid)
  #   child_pids.each_with_object(child_pids.dup) do |child_pid, acc|
  #     acc.concat(_recurse_child_pids(child_pid))
  #   end
  # end

    def next_track!
      puts "WARN: youtube does not support next_track!; no-op'ing."
    end

    def name
      "Youtube"
    end
  end
end
