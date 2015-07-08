module ActionPubsub
  class Subscriber < ::Concurrent::Actor::Utils::AdHoc
    class_attribute :concurrency, :queue, :exchange_prefix, :watches
    self.concurrency = 5

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
      puts "\n"
      puts "\n"
      puts ::ActionPubsub.exchange_registry[target_exchange][subscriber_key].inspect
      puts "HERE ^"
      puts "\n"
      ::ActionPubsub.exchange_registry[target_exchange][subscriber_key] << :subscribe
      -> message {
        puts message.inspect
        ::ActiveRecord::Base.connection_pool.with_connection do
          puts ::ActionPubsub.event_count.value
          sleep(1)
          ::ActionPubsub.event_count << proc{|current| current + 1 }
          sleep(1)
          puts ::ActionPubsub.event_count.value

          self.class.watches[message["action"]].call(message["record"])

          puts "CALLED WATCHER METHOD"

          self.class.bind_subscription(target_exchange, subscriber_key)
        end
      }
    end
  end
end
