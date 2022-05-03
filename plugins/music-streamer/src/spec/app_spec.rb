ENV["APP_ENV"] = "test"

require_relative "../app"
require "rspec"
require "rack/test"
require "pry-byebug"
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

    @settings_mock = double(:sockets => [], :worker_status= => "")
    @app_mock = double(:settings => @settings_mock)
    @worker_mock = MusicStreamerWorker.new("sig", @app_mock)

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
        allow(@worker_mock).to receive(:_thread) { |&block| block.call }

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

        allow(@worker_mock).to receive(:_thread) { |&block| block.call }

        stdin_mock = double(:puts => nil)
        stderr_mock = double
        wait_thr_mock = double
        stdout_mock = double(:read_nonblock => "Select station:")

        expect(ShellUtils).to receive(:popen3)
          .with(%Q(/bin/bash -lc 'pianobar'))
          .and_return([stdin_mock, stdout_mock, stderr_mock, wait_thr_mock])

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

  describe "/stream/stop" do
    context "when pandora is playing" do
      it "stops pianobar using the appropriate bash command" do
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
        expect(last_response.status).to eq(201)
      end
    end
  end

  describe "/pianobar_eventcmd" do
    it "updates websockets" do

    end

    it "updates current status" do

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
                    :muted => current_mute_status
                  }
                }
              }
            }
          }
          stub_request(:post, "192.168.0.23:1780/jsonrpc")
            .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"foo-bar-baz-id"}}))
            .to_return(:body => snapcast_get_status_response.to_json)


          stub_request(:post, "192.168.0.23:1780/jsonrpc")
            .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"foo-bar-baz-id","volume":{"muted":#{!current_mute_status}}}}))
            .to_return(:body => "{}")

          post "/snapcast/foo-bar-baz-id/toggle_mute"
        end
      end
    end
    # response_body_parsed = SnapcastGateway.get_status(params[:client_id])
    #
    # current_mute_status = response_body_parsed["result"]["client"]["config"]["volume"]["muted"]
    # new_mute_status = !current_mute_status
    #
    # SnapcastGateway.set_volume_muted(params[:client_id], new_mute_status)
    # 201
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
            }
          }
        }
      }
      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"foo-bar-baz-id"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"foo-bar-baz-id","volume":{"muted":false, "percent":75}}}))
        .to_return(:body => "{}")

      post "/snapcast/foo-bar-baz-id/volume_up"
    end

    it "does not exceed 100%" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 100
              }
            }
          }
        }
      }
      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"foo-bar-baz-id"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"foo-bar-baz-id","volume":{"muted":false, "percent":100}}}))
        .to_return(:body => "{}")

      post "/snapcast/foo-bar-baz-id/volume_up"
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
            }
          }
        }
      }
      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"foo-bar-baz-id"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"foo-bar-baz-id","volume":{"muted":false, "percent":65}}}))
        .to_return(:body => "{}")

      post "/snapcast/foo-bar-baz-id/volume_down"
    end

    it "does not go under 0%" do
      snapcast_get_status_response = {
        :result => {
          :client => {
            :config => {
              :volume => {
                :percent => 0
              }
            }
          }
        }
      }
      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"foo-bar-baz-id"}}))
        .to_return(:body => snapcast_get_status_response.to_json)


      stub_request(:post, "192.168.0.23:1780/jsonrpc")
        .with(:body => %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"foo-bar-baz-id","volume":{"muted":false, "percent":0}}}))
        .to_return(:body => "{}")

      post "/snapcast/foo-bar-baz-id/volume_down"
    end
  end
end
