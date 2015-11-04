module ActionPubsub
  class ExchangeRegistry < ::ActionPubsub::Registry
    def register_queue(exchange_name, subscriber_name)
      register_exchange(exchange_name) unless key?(exchange_name)
      queue_name = [exchange_name, subscriber_name].join("/")
      self[exchange_name].add(subscriber_name) { ::ActionPubsub::Queue.spawn(queue_name) }
    end

    def register_exchange(exchange_name)
      add(exchange_name) { ::ActionPubsub::ExchangeRegistry.new }
    end
  end
end
