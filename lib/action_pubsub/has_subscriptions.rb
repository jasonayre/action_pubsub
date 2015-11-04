module ActionPubsub
  module HasSubscriptions
    extend ::ActiveSupport::Concern

    included do
      class_attribute :_as
      class_attribute :subscriptions
      self.subscriptions = []
    end

    module ClassMethods
      def as(val)
        self._as = val
      end

      def on(*paths, as:nil, &block)
        _subscriptions = ::ActionPubsub.on(*paths, as:(as || _as), &block)
        _subscriptions.each { |_subscription| subscriptions << _subscription }
        subscriptions
      end
    end
  end
end
