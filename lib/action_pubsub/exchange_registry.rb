module ActionPubsub
  class ExchangeRegistry < ::Concurrent::LazyRegister
    def register_queue(exchange_name, subscriber_name)
      register_exchange(exchange_name) unless key?(exchange_name)
      exchange_hash = self[exchange_name].instance_variable_get("@data").value
      exchange_keys = exchange_hash.keys
      queue_name = [exchange_name, subscriber_name].join("/")
      self[exchange_name].add(subscriber_name) { ::ActionPubsub::Queue.spawn(queue_name) }
    end

    def register_exchange(exchange_name)
      add(exchange_name) { ::Concurrent::LazyRegister.new }
    end
  end
end
