ENV["APP_ENV"] = "test"

require_relative "../app"
require "rspec"
require "rack/test"
# Only uncomment when uncommenting require "irb" line in Gemfile
# require "pry-byebug"
require "webmock/rspec"

RSpec.describe "Full Stack" do
  include Rack::Test::Methods

  before(:all) do
    @event_machine_server_mock = Object.new
  end

  before(:each) do
    allow(ShellUtils).to receive(:spawn)
    allow(ShellUtils).to receive(:exec)
    allow(ShellUtils).to receive(:popen3)
    allow(ShellUtils).to receive(:wait)
    allow(SoundEffects).to receive(:_thread) { |&block| block.call }

    stub_request(:post, "192.168.5.227:1780/jsonrpc")
      .with(:body => %Q({"id":1,"jsonrpc":"2.0","method":"Server.GetStatus"}))
      .to_return(:body => File.read("spec/fixtures/snapcast_server_status_response.json"))

    @socket_mock = double
    allow(@socket_mock).to receive(:send)

    @settings_mock = double(:sockets => [@socket_mock], :worker_status= => "")
    @app_mock = double(:settings => @settings_mock)
    @worker_mock = MusicStreamerWorker.new("sig", @app_mock)
    allow(@worker_mock).to receive(:_thread) { |&block| block.call }

    allow(EventMachine).to receive(:start_server)
    allow(EM).to receive(:next_tick) { |&block| block.call }
    allow(EM).to receive(:connect).and_return(@event_machine_server_mock)
    allow(@event_machine_server_mock).to receive(:send_data) { |*args| @worker_mock.receive_data(*args) }
  end

  after(:each) do
    WebMock.reset!
  end

  def app
    MusicStreamerApplication
  end

  describe "/websocket/updates" do
    # if request.websocket?
    #   request.websocket do |ws|
    #     ws.onopen do
    #       ws.send(settings.worker_status)
    #       settings.sockets << ws
    #     end
    #
    #     ws.onclose do
    #       settings.sockets.delete(ws)
    #     end
    #   end
    # else
    #   404
    # end
    #
    it "gets current status when opening socket" do

    end

    it "gets updates on open socket" do

    end

    it "cleans up closed sockets" do

    end
  end

  describe "/stream/youtube" do
    describe "full stack" do
      it "streams the youtube channel using the appropriate bash command" do
        pid_mock = double
        expect(ShellUtils).to receive(:spawn)
          .with(%Q(/bin/bash -c " ffplay -nodisp <(youtube-dl -f 96  'https://www.youtube.com/watch?v=5qap5aO4i9A' -o -) 2> /dev/null"))
          .and_return(pid_mock)

        expect(ShellUtils).to receive(:wait)
          .with(pid_mock)

        expect(@settings_mock).to receive(:worker_status=)
          .with("Starting...")
          .ordered
        expect(@settings_mock).to receive(:worker_status=)
          .with("Youtube")
          .ordered

        post "/stream/youtube"
        expect(last_response.status).to eq(201)
      end
    end
  end

  describe "/stream/pandora_radio" do
    describe "full stack" do
      it "streams the pandora station using the approriate string of pianobar STDIN commands" do
        stdin_mock = double(:puts => nil)
        stderr_mock = double
        wait_thr_mock = double
        stdout_mock = double(:read_nonblock => "Select station:")

        expect(ShellUtils).to receive(:popen3)
          .with(%Q(/bin/bash -lc 'pianobar'))
          .and_return([stdin_mock, stdout_mock, stderr_mock, wait_thr_mock])

        expect(stdin_mock).to receive(:puts).with(26)

        expect(@settings_mock).to receive(:worker_status=)
          .with("Starting...")
          .ordered
        expect(@settings_mock).to receive(:worker_status=)
          .with("Pandora")
          .ordered

        post "/stream/pandora_radio"
        expect(last_response.status).to eq(201)
      end
    end
  end

  describe "/stream/next_track" do
    it "sends the 'next' command to pianobar" do
      stdin_mock = double(:puts => nil)
      stderr_mock = double
      wait_thr_mock = double
      stdout_mock = double(:read_nonblock => "Select station:")

      expect(ShellUtils).to receive(:popen3)
        .with(%Q(/bin/bash -lc 'pianobar'))
        .and_return([stdin_mock, stdout_mock, stderr_mock, wait_thr_mock])

      post "/stream/pandora_radio"

      expect(@settings_mock).to receive(:worker_status=)
        .with("Skipping...")
        .ordered
      expect(@settings_mock).to receive(:worker_status=)
        .with("Skipped")
        .ordered
      expect(stdin_mock).to receive(:puts).with("n")

      expect(ShellUtils).not_to receive(:exec).with(/ffplay/)
      post "/stream/next_track"
      expect(last_response.status).to eq(201)
    end
  end

  describe "/stream/next_track/:client_id" do
    it "sends the 'next' command to pianobar" do
      stdin_mock = double(:puts => nil)
      stderr_mock = double
      wait_thr_mock = double
      stdout_mock = double(:read_nonblock => "Select station:")

      expect(ShellUtils).to receive(:popen3)
        .with(%Q(/bin/bash -lc 'pianobar'))
        .and_return([stdin_mock, stdout_mock, stderr_mock, wait_thr_mock])

      post "/stream/pandora_radio"

      expect(@settings_mock).to receive(:worker_status=)
        .with("Skipping...")
        .ordered
      expect(@settings_mock).to receive(:worker_status=)
        .with("Skipped")
        .ordered
      expect(stdin_mock).to receive(:puts).with("n")

      expect(ShellUtils).to receive(:exec).with(%Q(/bin/bash -c "PULSE_SERVER=tcp:192.168.0.26:4317 ffplay -volume 50 -autoexit -nodisp assets/jambox_on.mp3 2> /dev/null"))
      post "/stream/next_track/ba6e0fc699945fa7dc028733455dfb88"
      expect(last_response.status).to eq(201)
    end
  end

  describe "/stream/stop" do
    context "when pandora is playing" do
      it "stops pianobar using the appropriate bash command" do
        stdin_mock = double(:puts => nil)
        stderr_mock = double
        wait_thr_mock = double
        stdout_mock = double(:read_nonblock => "Select station:")

        expect(ShellUtils).to receive(:popen3)
          .with(%Q(/bin/bash -lc 'pianobar'))
          .and_return([stdin_mock, stdout_mock, stderr_mock, wait_thr_mock])
        post "/stream/pandora_radio"
        expect(last_response.status).to eq(201)

        expect(ShellUtils).to receive(:exec)
          .with("killall pianobar")
        post "/stream/stop"
        expect(last_response.status).to eq(201)
      end
    end

    context "when youtube is playing" do
      it "stops ffplay using the appropriate bash command" do
        post "/stream/youtube"

        expect(ShellUtils).to receive(:exec)
          .with("killall ffplay")
        post "/stream/stop"
        expect(last_response.status).to eq(201)
      end
    end

    context "when nothing is playing" do
      it "does nothing" do
        post "/stream/stop"
        expect_any_instance_of(AudioStreamSource).not_to receive(:stop!)
        expect(last_response.status).to eq(201)
      end
    end

    context "when already stopped" do
      it "does nothing" do
        post "/stream/youtube"
        post "/stream/stop"

        expect_any_instance_of(AudioStreamSource::Youtube).not_to receive(:stop!)
        post "/stream/stop"
        expect(last_response.status).to eq(201)
      end
    end
  end

  describe "/pianobar_eventcmd" do
    it "updates websockets and clears io" do
      pandora_mock = double
      @worker_mock.instance_variable_set("@audio_stream_source", pandora_mock)
      expect(@settings_mock).to receive(:worker_status=)
        .with("TOOL - Jimmy (songstart)")
      expect(pandora_mock).to receive(:clear_io!)
      post "pianobar_eventcmd", File.read("spec/fixtures/pianobar_eventcmd.json")
    end
  end

  describe "/snapcast/:client_id/toggle_mute" do
    [true, false].each do |current_mute_status|
      context "current_mute_status=#{current_mute_status}" do
        it "makes a snapcast API call to get current mute status, and another api call to toggle it" do

          snapcast_get_status_response = {
            :result => {
              :client => {
                :config => {
                  :volume => {
                    :muted => current_mute_status,
                    :percent => 50,
                  }
                },
              }
            }
          }
          stub_request(:post, "192.168.5.227:1780/jsonrpc")
            .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"ba6e0fc699945fa7dc028733455dfb88"}}))
            .to_return(:body => snapcast_get_status_response.to_json)


          stub_request(:post, "192.168.5.227:1780/jsonrpc")
            .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"ba6e0fc699945fa7dc028733455dfb88","volume":{"muted":#{!current_mute_status}}}}))
            .to_return(:body => "{}")

          expect(ShellUtils).to receive(:exec).with(%Q(/bin/bash -c "PULSE_SERVER=tcp:192.168.0.26:4317 ffplay -volume 50 -autoexit -nodisp assets/jambox_#{current_mute_status ? "on" : "off"}.mp3 2> /dev/null"))
          post "/snapcast/ba6e0fc699945fa7dc028733455dfb88/toggle_mute"
        end
      end
    end
  end

  describe "/snapcast/:client_id/volume_up" do
    it "makes a snapcast API call to increase volume by 5% and also unmutes" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 70
              }
            },
          }
        }
      }
      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"ba6e0fc699945fa7dc028733455dfb88"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"ba6e0fc699945fa7dc028733455dfb88","volume":{"muted":false, "percent":75}}}))
        .to_return(:body => "{}")

      expect(ShellUtils).to receive(:exec).with(%Q(/bin/bash -c "PULSE_SERVER=tcp:192.168.0.26:4317 ffplay -volume 50 -autoexit -nodisp assets/jambox_volume_change.mp3 2> /dev/null"))
      post "/snapcast/ba6e0fc699945fa7dc028733455dfb88/volume_up"
    end

    it "does not exceed 100%" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 100
              }
            },
          }
        }
      }
      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"ba6e0fc699945fa7dc028733455dfb88"}}))
        .to_return(:body => snapcast_get_status_response.to_json)

      post "/snapcast/ba6e0fc699945fa7dc028733455dfb88/volume_up"
    end
  end

  describe "/snapcast/:client_id/volume_down" do
    it "makes a snapcast API call to decrease volume by 5% and also unmutes" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 70
              }
            },
          }
        }
      }
      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"ba6e0fc699945fa7dc028733455dfb88"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"ba6e0fc699945fa7dc028733455dfb88","volume":{"muted":false, "percent":65}}}))
        .to_return(:body => "{}")

      expect(ShellUtils).to receive(:exec).with(%Q(/bin/bash -c "PULSE_SERVER=tcp:192.168.0.26:4317 ffplay -volume 50 -autoexit -nodisp assets/jambox_volume_change.mp3 2> /dev/null"))
      post "/snapcast/ba6e0fc699945fa7dc028733455dfb88/volume_down"
    end

    it "does not go under 0%" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 0
              }
            },
          }
        }
      }
      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"ba6e0fc699945fa7dc028733455dfb88"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.5.227:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"ba6e0fc699945fa7dc028733455dfb88","volume":{"muted":false, "percent":0}}}))
        .to_return(:body => "{}")

      post "/snapcast/ba6e0fc699945fa7dc028733455dfb88/volume_down"
    end
  end

  describe "/stream/pandora_radio/debug" do
    it "provides debug information about the pianobar bash process" do
      @pandora_mock = double
      expect(@pandora_mock).to receive(:get_debug_string).and_return("debug string foo")
      expect(@socket_mock).to receive(:send).with("debug string foo")
      @worker_mock.instance_variable_set("@audio_stream_source", @pandora_mock)
      post "/stream/pandora_radio/debug"
      expect(last_response.status).to eq(200)
    end
  end
end
