module ActionPubsub
  module ActiveRecord
    extend ::ActiveSupport::Autoload

    autoload :Events
    autoload :OnChange
    autoload :Publishable
    autoload :Subscriber
    autoload :Subscription
    autoload :WithConnection
  end
end
