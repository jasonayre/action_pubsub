module ActionPubsub
  module ActiveRecord
    class Subscription < ::Concurrent::Actor::Utils::AdHoc
      class_attribute :subscriber

      def self.bind_subscription(target_exchange, subscriber_key)
        ::ActionPubsub.exchanges[target_exchange][subscriber_key] << :subscribe
        -> message {
          ::ActiveRecord::Base.connection_pool.with_connection do
            should_rebind = begin
              puts "1"
              puts "a"
              puts ""
              message = ::ActionPubsub.deserialize_event(message)
              puts ""
              puts ""
              reaction = self.class.subscriber.reactions[message["action"]]
              record = message["record"]
              puts ""
              puts "record"

              if self.class.subscriber.react?(message["action"], reaction, record)
                puts "REACTING TO IT"
                self.class.subscriber.increment_event_triggered_count!
                subscriber_instance = self.class.subscriber.new(record)
                subscriber_instance.instance_exec(record, &reaction[:block])
              end

              puts "end of success block"

              true
            rescue => e
              puts "INSIDE RESCUE"
              message = ::ActionPubsub.deserialize_event(message)

              # failure_message = ::ActionPubsub::Errors::SubscriptionReactionErrorMessage.new(
              #   :target_exchange => target_exchange,
              #   :subscriber_key => subscriber_key,
              #   :error => e,
              #   :message => message
              # )
              #
              # ::ActionPubsub.config._on_error_block.call(failure_message) if ::ActionPubsub.config._on_error_block
              #don't rebind if message is a symbol
              !message.is_a?(Symbol)
            end

            puts "REBINDING"
            puts "#{self.class.name}"
            self.class.bind_subscription(target_exchange, subscriber_key) if should_rebind
          end
        }
      end
    end
  end
end
