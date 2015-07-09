module ActionPubsub
  module ActiveRecord
    class Subscription < ::Concurrent::Actor::Utils::AdHoc
      class_attribute :subscriber

      def self.bind_subscription(target_exchange, subscriber_key)
        ::ActionPubsub.exchange_registry[target_exchange][subscriber_key] << :subscribe
        -> message {
          ::ActiveRecord::Base.connection_pool.with_connection do
            reaction = self.class.subscriber.reactions[message["action"]]

            if self.class.subscriber.react?(message["action"], reaction, message["record"])
              subscriber_instance = self.class.subscriber.new(message["record"])
              subscriber_instance.instance_exec(message["record"], &reaction[:block])
            end

            self.class.bind_subscription(target_exchange, subscriber_key)
          end
        }
      end
    end
  end
end
