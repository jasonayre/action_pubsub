require 'active_support/ordered_options'

module ActionPubsub
  class Config < ::ActiveSupport::InheritableOptions
    def initialize(*args)
      super(*args)

      self[:debug] = false
      self[:serializer] = nil
    end

    def debug=(val)
      ::Concurrent.use_stdlib_logger(Logger::DEBUG) if val
    end

    def serializer=(val)
      if val && val.ancestors.include?(::ActiveSupport::Concern)
        ::ActionPubsub.include(val)
      end
    end
  end
end
