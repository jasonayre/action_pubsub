module ActionPubsub
  class Exchanges < ::ActionPubsub::Registry
    def register_queue(exchange_name, subscriber_name)
      queue_name = [exchange_name, subscriber_name].join("/")
      puts "REGISTERING QUEUE FOR"
      puts "#{queue_name}"
      self[exchange_name].add(subscriber_name) { ::ActionPubsub::Queue.spawn(queue_name) }
    end

    def register_exchange(exchange_name)
      add(exchange_name) { ::ActionPubsub::Exchanges.new }
      self[exchange_name]
    end

    def [](val)
      return super(val) if key?(val)

      add(val){ ::ActionPubsub::Exchanges.new  }
      super(val)
    end
  end
end
