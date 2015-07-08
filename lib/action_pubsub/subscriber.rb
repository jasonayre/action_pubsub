module ActionPubsub
  class Subscriber < ::Concurrent::Actor::Utils::AdHoc
    def self.inherited(subklass)
      super(subklass)
      subklass.class_attribute :channel
    end

    def self.method_added(method_name)
      super(method_name)
      routing_key = [channel, method_name].join("/")

      ::ActionPubsub.register_channel(routing_key)

      spawn(routing_key) do
        ::ActionPubsub.channel_registry[routing_key] << :subscribe
        -> message {
          sleep(10)

          puts message.inspect

          target_klass, target_method = ::ActionPubsub.destination(path)

          __send__(target_method, message["record"])

          puts some_thing.inspect

          puts "AFTER SLEEP"
          puts message.inspect
          puts self.inspect
          puts self.class.inspect
        }
      end
      # ::Concurrent::Actor::Utils::AdHoc.spawn "listener-#{i}" do
      #   news_channel << :subscribe
      #   -> message { puts message }
      # end

      # if()
      # if public_method_defined?(event) && notifier
      #   add_event_subscriber(method_name)
      # end
    end

    module ClassMethods
      def on_create(options = {}, &block)
        @_on_create.merge!(options.merge!(:block => block))
      end

      def on_change(*attribute_names, &block)
        options = attribute_names.extract_options!

        attribute_names.each do |attribute|
          @_on_change_watches[attribute] = { :block => block }
          @_on_change_watches[attribute].merge!(options)
        end
      end

      def on_update(options = {}, &block)
        @_on_update.merge!(options.merge!(:block => block))
      end

      def execute_on_create_block?(resource)
        return false if instance_variable_get("@_on_create").blank?
        result = true
        result &&= !@_on_create[:unless].call(resource) if @_on_create.key?(:unless)
        result &&= @_on_create[:if].call(resource) if @_on_create.key?(:if)
        return result
      end

      def execute_on_update_block?(resource)
        return false if instance_variable_get("@_on_update").blank?
        result = true
        result &&= !@_on_update[:unless].call(resource) if @_on_update.key?(:unless)
        result &&= @_on_update[:if].call(resource) if @_on_update.key?(:if)
        return result
      end

      #note: we cant use attribute_changed? because we care about previous changes here
      def execute_changed_block?(resource, attribute_name, value)
        old_value, new_value = value
        return false unless watching_attribute?(attribute_name)
        result = true
        result &&= old_value == watched_attributes[attribute_name][:from] if watched_attributes[attribute_name].key?(:from)
        result &&= new_value == watched_attributes[attribute_name][:to] if watched_attributes[attribute_name].key?(:to)
        result &&= watched_attributes[attribute_name][:if].call(resource) if watched_attributes[attribute_name].key?(:if)
        result &&= !watched_attributes[attribute_name][:unless].call(resource) if watched_attributes[attribute_name].key?(:unless)
        return result
      end

      def watching_attribute?(attribute_name)
        watched_attributes.key?(attribute_name)
      end

      def watched_attributes
        self.instance_variable_get(:@_on_change_watches)
      end
    end

    # module AfterCommitOnCreate
    #   extend ::ActiveSupport::Concern
    #
    #   def after_commit_on_create(*args)
    #     @resource = args.first
    #
    #     if self.class.execute_on_create_block?(resource)
    #       instance_exec(*args, &self.class.instance_variable_get(:@_on_create)[:block])
    #     end
    #   end
    # end
    #
    # module AfterCommitOnChange
    #   extend ::ActiveSupport::Concern
    #
    #   def after_commit_on_update(*args)
    #     @resource = args.first
    #
    #     resource.previous_changes.each_pair do |k,vals|
    #       if self.class.execute_changed_block?(resource, k, vals)
    #         old_value, new_value = vals
    #         instance_exec(new_value, old_value, &self.class.watched_attributes[k][:block])
    #       end
    #     end
    #   end
    # end
    #
    # module AfterCommitOnUpdate
    #   extend ::ActiveSupport::Concern
    #
    #   def after_commit_on_update(*args)
    #     @resource = args.first
    #
    #     if self.class.execute_on_update_block?(resource)
    #       instance_exec(*args, &self.class.instance_variable_get(:@_on_update)[:block])
    #     end
    #   end
    # end

  end
end
    # class Worker < Concurrent::Actor::RestartingContext
    #   def on_message(message)
    #     p message * 5
    #   end
    # end
