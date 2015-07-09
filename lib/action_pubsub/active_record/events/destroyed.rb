module ActionPubsub
  module ActiveRecord
    module Events
      module Destroyed
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_destroyed_event, :on => :create

          routing_key = [exchange_prefix, "destroyed"].join("/")
          ::ActionPubsub.register_exchange(routing_key)
        end

        def publish_destroyed_event
          routing_key = [self.class.exchange_prefix, "destroyed"].join("/")

          record_destroyed_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActiveRecord::Base.connection_pool.with_connection do
            ::ActionPubsub.publish_event(routing_key, record_destroyed_event)
          end
        end
      end
    end
  end
end
