module ActionPubsub
  module ActiveRecord
    module OnChange
      extend ::ActiveSupport::Concern

      included do
        class << self
          attr_accessor :_on_change_watches
        end

        @_on_change_watches = {}.with_indifferent_access
      end

      module ClassMethods
        def on_change(*attribute_names, &block)
          options = attribute_names.extract_options!

          attribute_names.each do |attribute|
            @_on_change_watches[attribute] = { :block => block }
            @_on_change_watches[attribute].merge!(options)
          end

          on :changed do |record|
            record.previous_changes.each_pair do |k,vals|
              if self.class.react_to_changed?(record, k, vals)
                old_value, new_value = vals
                self.instance_exec(new_value, old_value, &self.class.watched_attributes[k][:block])
              end
            end
          end
        end

        def react_to_changed?(resource, attribute_name, value)
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
    end
  end
end
