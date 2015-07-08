module ActionPubsub
  class Performer < Concurrent::Actor::RestartingContext
    def on_message(message)
      p message * 5
    end

    def self.inherited(subklass)

    end
  end
end
