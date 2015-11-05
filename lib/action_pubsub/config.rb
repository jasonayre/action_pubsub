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

    ### not working atm
    def disabled=(val)
      if val
        ::Concurrent::Actor::Root.instance_variable_set("@dead_letter_router",
          ::ActionPubsub.silent_dead_letter_handler
        )
      end
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
