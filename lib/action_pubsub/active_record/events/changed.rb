module ActionPubsub
  module ActiveRecord
    module Events
      module Changed
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_changed_event, :on => :update

          routing_key = [exchange_prefix, "changed"].join("/")
          ::ActionPubsub.register_exchange(routing_key)
        end

        def publish_changed_event
          routing_key = [self.class.exchange_prefix, "changed"].join("/")

          record_changed_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActiveRecord::Base.connection_pool.with_connection do
            ::ActionPubsub.publish_event(routing_key, record_changed_event)
          end
        end
      end
    end
  end
end
