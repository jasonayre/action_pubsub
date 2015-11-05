module ActionPubsub
  module Actors
    module SilenceDeadLetters
      def on_message(dead_letter)
        puts "YOUR MOM"
        puts dead_letter.inspect
      end
    end
  end
end
