require 'active_model'

module ActionPubsub
  module Errors
    class SubscriptionReactionErrorMessage
      attr_accessor :message, :error, :target_exchange, :subscriber_key

      def initialize(*args, message:, error:, target_exchange:nil, subscriber_key:nil, **options)
        @message = message
        @error = error
        @target_exchange = target_exchange
        @subscriber_key = subscriber_key
      end
    end
  end
end
