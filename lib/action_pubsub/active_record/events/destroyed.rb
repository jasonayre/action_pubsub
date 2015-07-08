module ActionPubsub
  module ActiveRecord
    module Events
      module Destroyed
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_destroyed_event, :on => :create
        end

        def publish_destroyed_event
          routing_key = [self.class.channel, "destroyed"].join("/")

          record_destroyed_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActionPubsub.publish_event(routing_key, record_destroyed_event)
        end
      end
    end
  end
end
