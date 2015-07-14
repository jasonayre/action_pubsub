module ActionPubsub
  module ActiveRecord
    class Subscription < ::Concurrent::Actor::Utils::AdHoc
      class_attribute :subscriber

      def self.bind_subscription(target_exchange, subscriber_key)
        ::ActionPubsub.exchange_registry[target_exchange][subscriber_key] << :subscribe
        -> message {
          ::ActiveRecord::Base.connection_pool.with_connection do
            message = ::ActionPubsub.deserialize_event(message)
            reaction = self.class.subscriber.reactions[message["action"]]
            record = message["record"]

            if self.class.subscriber.react?(message["action"], reaction, record)
              self.class.subscriber.increment_event_triggered_count!

              subscriber_instance = self.class.subscriber.new(record)
              subscriber_instance.instance_exec(record, &reaction[:block])
            end

            self.class.bind_subscription(target_exchange, subscriber_key)
          end
        }
      end
    end
  end
end
