module ActionPubsub
  module ActiveRecord
    extend ::ActiveSupport::Autoload

    autoload :Publishable
    autoload :Events
    autoload :Subscriber
  end
end
