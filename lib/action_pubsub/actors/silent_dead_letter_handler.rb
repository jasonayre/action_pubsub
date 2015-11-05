#dead letter routing not working ATM
module ActionPubsub
  module Actors
    class SilentDeadLetterHandler < ::Concurrent::Actor::RestartingContext
      def on_messaage(dead_letter)
        puts "SILENCE DEAD LETTER HANDLER GOT MESSAGE"
        puts dead_letter.inspect
        super(dead_letter)
      end
    end
  end
end
