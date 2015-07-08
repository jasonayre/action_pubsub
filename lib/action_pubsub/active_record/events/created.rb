module ActionPubsub
  module ActiveRecord
    module Events
      module Created
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_created_event, :on => :create
        end

        def publish_created_event
          routing_key = [self.class.channel, "created"].join("/")

          record_created_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActionPubsub.publish_event(routing_key, record_created_event)
        end
      end
    end
  end
end
