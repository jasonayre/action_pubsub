module ActionPubsub
  module Actors
    extend ::ActiveSupport::Autoload

    autoload :SilenceDeadLetters
    autoload :SilentDeadLetterHandler
  end
end
