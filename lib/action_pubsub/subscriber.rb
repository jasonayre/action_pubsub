module ActionPubsub
  class Subscriber < ::Concurrent::Actor::Utils::AdHoc
    class_attribute :concurrency, :queue, :exchange_prefix, :watches
    self.concurrency = 1

    def self.inherited(subklass)
      subklass.watches = {}
    end

    def self.register_event_watcher(event_name)
      target_exchange = [exchange_prefix, event_name].join("/")
      subscriber_key = name.underscore
      queue_key = [target_exchange, subscriber_key].join("/")

      ::ActionPubsub.register_queue(target_exchange, subscriber_key)

      self.concurrency.times do |i|
        spawn("#{queue_key}/#{i}") do
          bind_subscription(target_exchange, subscriber_key)
        end
      end
    end

    def self.on(event_name, &block)
      watches[event_name] = block
      register_event_watcher(event_name)
    end

    def self.bind_subscription(target_exchange, subscriber_key)
      ::ActionPubsub.exchange_registry[target_exchange][subscriber_key] << :subscribe
      -> message {
        self.class.watches[message["action"]].call(message["record"])

        self.class.bind_subscription(target_exchange, subscriber_key)
      }
    end
  end
end
