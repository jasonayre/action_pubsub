module ActionPubsub
  module ActiveRecord
    module Publishable
      extend ActiveSupport::Concern

      PUBLISHABLE_EVENTS = {
        :updated =>   ::ActionPubsub::ActiveRecord::Events::Updated,
        :created =>   ::ActionPubsub::ActiveRecord::Events::Created,
        :destroyed => ::ActionPubsub::ActiveRecord::Events::Destroyed
      }

      included do
        include ::ActiveModel::Dirty unless ancestors.include?(::ActiveModel::Dirty)

        class_attribute :exchange_prefix

        class << self
          attr_accessor :_publishable_actions
        end
      end

      ### todo: investigate why specs break if && hash is omitted
      def attributes_hash
        hash = self.as_json
        hash.merge!(:changes => previous_changes) if previous_changes && hash
        hash.symbolize_keys! if hash
        hash
      end

      private

      def serialized_resource
        attributes_hash
        # Marshal.dump(attributes_hash)
      end

      module ClassMethods
        def publishable_actions(*actions)
          @_publishable_actions = actions

          actions.each do |action|
            include PUBLISHABLE_EVENTS[action] unless ancestors.include?(PUBLISHABLE_EVENTS[action])
          end
        end
      end
    end
  end
end
