module ActionPubsub
  class Balancer < ::Concurrent::Actor::Utils::Balancer

    def initialize
      @receivers = []
      @buffer    = []
    end

    def on_message(message)
      case message
      when :subscribe
        @receivers << envelope.sender
        distribute
        true
      when :unsubscribe
        @receivers.delete envelope.sender
        true
      when :subscribed?
        @receivers.include? envelope.sender
      else
        @buffer << envelope
        distribute
        ::Concurrent::Actor::Behaviour::MESSAGE_PROCESSED
      end
    end

    def distribute
      while !@receivers.empty? && !@buffer.empty?
        redirect @receivers.shift, @buffer.shift
      end
    end

    def dead_letter_routing
      ::ActionPubsub.silent_dead_letter_handler
    end
  end
end
