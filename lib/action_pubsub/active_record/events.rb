module ActionPubsub
  module ActiveRecord
    module Events
      extend ::ActiveSupport::Autoload

      autoload :Created
      autoload :Destroyed
      autoload :Updated
    end
  end
end
