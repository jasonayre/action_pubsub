module ActionPubsub
  class Subscriber < ::Concurrent::Actor::Utils::AdHoc
    class_attribute :concurrency, :channel, :watches
    self.concurrency = 2
    self.watches = {}

    def self.register_event_watcher(event_name)
      observed_routing_key = [channel, event_name].join("/")
      subscriber_key = name.underscore

      ::ActionPubsub.register_channel(observed_routing_key)

      self.concurrency.times do |i|
        spawn("#{subscriber_key}/#{i}") do
          bind_subscription(observed_routing_key)
        end
      end
    end

    def self.on(event_name, &block)
      watches[event_name] = block
      register_event_watcher(event_name)
    end

    def self.bind_subscription(observed_routing_key)
      ::ActionPubsub.channel_registry[observed_routing_key] << :subscribe
      -> message {
        ::ActiveRecord::Base.connection_pool.with_connection do
          puts ::ActionPubsub.event_count.value
          sleep(1)
          ::ActionPubsub.event_count << proc{|current| current + 1 }
          sleep(1)
          puts ::ActionPubsub.event_count.value

          target_klass, target_method = ::ActionPubsub.destination_tuple_from_sender_path(envelope.sender.path)

          self.class.watches[target_method.to_sym].call(message["record"])

          self.class.bind_subscription(observed_routing_key)
        end
      }
    end
  end
end
