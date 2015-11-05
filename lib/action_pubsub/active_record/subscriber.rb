module ActionPubsub
  module ActiveRecord
    class Subscriber
      class_attribute :concurrency,
                      :event_triggered_count,
                      :event_processed_count,
                      :event_failed_count,
                      :observed_exchanges,
                      :messages_received_count,
                      :messages_processed_count,
                      :queue,
                      :reactions,
                      :subscription

      self.concurrency = 1

      attr_accessor :resource, :current_event

      #the indirection here with the "subscription" dynamically created class, is for the sake
      #of making subscribers immutable and not storing instance state.
      #i.e. subscription is the actual actor, which just instantiates this subscriber class
      #and performs the task it needs to
      def self.inherited(subklass)
        subklass.subscription = subklass.const_set("Subscription", ::Class.new(::ActionPubsub::ActiveRecord::Subscription))
        subklass.subscription.subscriber = subklass
        subklass.reactions = {}
        subklass.observed_exchanges = ::Set.new
        subklass.event_triggered_count = ::Concurrent::AtomicFixnum.new(0)
        subklass.event_failed_count = ::Concurrent::AtomicFixnum.new(0)
        subklass.event_processed_count = ::Concurrent::AtomicFixnum.new(0)
      end

      def self.disable_all!
      end

      def self.on(event_name, **options, &block)
        reactions[event_name] = {}.tap do |hash|
          hash[:block] = block
          hash[:conditions] = options.extract!(:if, :unless)
        end

        register_reaction_to_event(event_name)
      end

      def self.increment_event_failed_count!
        self.event_failed_count.increment
      end

      def self.increment_event_processed_count!
        self.event_processed_count.increment
      end

      def self.increment_event_triggered_count!
        self.event_triggered_count.increment
      end

      def self.subscribe_to(*exchanges)
        exchanges.each{ |exchange| self.observed_exchanges << exchange }
      end

      def self.react?(event_name, reaction, record)
        return false if reaction[:block].blank?
        return true if reaction[:conditions].blank?
        result = true
        result &&= !reaction[:conditions][:unless].call(record) if reaction[:conditions].key?(:unless)
        result &&= reaction[:conditions][:if].call(record) if reaction[:conditions].key?(:if)
        return result
      end

      def self.register_reaction_to_event(event_name)
        observed_exchanges.each do |exchange_prefix|
          target_exchange = [exchange_prefix, event_name].join("/")
          subscriber_key = name.underscore
          queue_key = [target_exchange, subscriber_key].join("/")
          ::ActionPubsub.register_queue(target_exchange, subscriber_key)

          self.concurrency.times do |i|
            queue_address = "#{queue_key}/#{i}"
            ::ActionPubsub.subscriptions[queue_address] ||= self.subscription.spawn(queue_address) do
              self.subscription.bind_subscription(target_exchange, subscriber_key)
            end
          end
        end
      end

      ### Instance Methods ###
      def initialize(record, event:nil)
        @resource = record
        @current_event = event if event
      end
    end
  end
end
