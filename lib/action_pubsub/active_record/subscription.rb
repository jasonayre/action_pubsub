module ActionPubsub
  module ActiveRecord
    class Subscription < ::Concurrent::Actor::Utils::AdHoc
      class_attribute :subscriber

      def self.bind_subscription(target_exchange, subscriber_key)
        ::ActionPubsub.exchanges[target_exchange][subscriber_key] << :subscribe
        -> message {
          ::ActiveRecord::Base.connection_pool.with_connection do
            begin
              message = ::ActionPubsub.deserialize_event(message)
              reaction = self.class.subscriber.reactions[message["action"]]
              record = message["record"]

              if self.class.subscriber.react?(message["action"], reaction, record)
                self.class.subscriber.increment_event_triggered_count!
                subscriber_instance = self.class.subscriber.new(record)
                subscriber_instance.instance_exec(record, &reaction[:block])
              end

              self.class.bind_subscription(target_exchange, subscriber_key)
            rescue => e
              #ensure we rebind subscription regardless
              self.class.bind_subscription(target_exchange, subscriber_key) unless message.is_a?(Symbol)
              message = ::ActionPubsub.deserialize_event(message)

              failure_message = ::ActionPubsub::Errors::SubscriptionReactionErrorMessage.new(
                :target_exchange => target_exchange,
                :subscriber_key => subscriber_key,
                :error => e,
                :message => message
              )

              ::ActionPubsub.config._on_error_block.call(failure_message) if ::ActionPubsub.config._on_error_block
            end
          end
        }
      end
    end
  end
end
