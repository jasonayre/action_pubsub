module ActionPubsub
  module ActiveRecord
    module Events
      module Updated
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_updated_event, :on => :create
        end

        def publish_updated_event
          routing_key = [self.class.channel, "updated"].join("/")

          record_updated_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActionPubsub.publish_event(routing_key, record_updated_event)
        end
      end
    end
  end
end
