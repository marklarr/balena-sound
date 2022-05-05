class AudioStreamSource
  class Base
    def initialize(message)

    end

    def start!
      raise NotImplementedError
    end

    def stop!
      raise NotImplementedError
    end

    def next_track!
      raise NotImplementedError
    end

    def name
      raise NotImplementedError
    end

    def get_debug_string
      raise NotImplementedError
    end
  end
end
