require 'trax_core'

module ActionPubsub
  class Types < ::Trax::Core::Blueprint
    class SubscriptionReactionError < ::Trax::Core::Types::Struct
      string :target_exchange
      string :subscriber_key

      attr_accessor :message, :error

      def initialize(*args, message:, error:, **options)
        super(*args, **options)

        @message = message
        @error = error
      end
    end
  end
end
