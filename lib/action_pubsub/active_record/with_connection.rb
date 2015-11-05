module ActionPubsub
  module ActiveRecord
    module WithConnection
      extend ::ActiveSupport::Concern

      module ClassMethods
        def on(*paths, as:nil, &block)
          wrapped_block = lambda{ |message|
            ::ActiveRecord::Base.connection_pool.with_connection { block.call(message) }
          }

          _subscriptions = ::ActionPubsub.on(*paths, as:(as || _as), &wrapped_block)
          _subscriptions.each { |_subscription| subscriptions << _subscription }
          subscriptions
        end
      end
    end
  end
end
