module ActionPubsub
  module ActiveRecord
    extend ::ActiveSupport::Autoload

    autoload :Publishable
    autoload :Events
  end
end
