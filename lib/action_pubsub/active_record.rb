module ActionPubsub
  module ActiveRecord
    extend ::ActiveSupport::Autoload

    autoload :Events
    autoload :Publishable
    autoload :Subscriber
    autoload :Subscription
  end
end
