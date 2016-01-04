module ActionPubsub
  class Exchanges < ::ActionPubsub::Registry
    def register_queue(exchange_name, subscriber_name)
      queue_name = [exchange_name, subscriber_name].join("/")
      queue_exists = self[exchange_name].all.any?{ |queue| queue.name == queue_name }
      self[exchange_name].add(subscriber_name) { ::ActionPubsub::Queue.spawn(queue_name) } unless queue_exists
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
