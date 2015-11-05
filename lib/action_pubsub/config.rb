require 'active_support/ordered_options'

module ActionPubsub
  class Config < ::ActiveSupport::InheritableOptions
    def initialize(*args)
      super(*args)

      self[:debug] = false
      self[:disabled] = false
      self[:serializer] = nil
      self[:_on_error_block] = nil
    end

    def debug=(val)
      ::Concurrent.use_stdlib_logger(Logger::DEBUG) if val
    end

    def disabled?
      self[:disabled]
    end

    def serializer=(val)
      if val && val.ancestors.include?(::ActiveSupport::Concern)
        ::ActionPubsub.include(val)
      end
    end

    def on_error(&block)
      self[:_on_error_block] = block
    end
  end
end
