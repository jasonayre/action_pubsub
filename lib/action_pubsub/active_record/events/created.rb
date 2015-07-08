module ActionPubsub
  module ActiveRecord
    module Events
      module Created
        extend ::ActiveSupport::Concern

        included do
          after_commit :publish_created_event, :on => :create

          routing_key = [channel, "created"].join("/")
          ::ActionPubsub.register_channel(routing_key) unless ::ActionPubsub.channels.key?(routing_key)
        end

        def publish_created_event
          puts "CALLING PUBLISH CREATED EVENT"
          routing_key = [self.class.channel, "created"].join("/")

          record_created_event = ::ActionPubsub::Event.new(
            :topic => routing_key,
            :record => self
          )

          ::ActiveRecord::Base.connection_pool.with_connection do
            ::ActionPubsub.publish_event(routing_key, record_created_event)
          end
        end
      end
    end
  end
end
