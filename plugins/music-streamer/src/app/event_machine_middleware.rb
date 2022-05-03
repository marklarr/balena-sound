class EventMachineMiddleWare
  def initialize(app, options = {})
    @app = app
    EM::next_tick do
      @event_machine_server = EM::connect('127.0.0.1', 4000, MusicStreamerWorker, self)
    end
  end

  def call(env)
    env['event_machine_server'] = @event_machine_server
    @app.call(env)
  end
end
