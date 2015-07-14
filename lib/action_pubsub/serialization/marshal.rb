module ActionPubsub
  module Serialization
    module Marshal
      extend ActiveSupport::Concern

      module Marshal
        def self.serialize_event(event)
          ::Marshal.dump(super(event))
        end

        def self.deserialize_event(event)
          ::Marshal.load(super(event))
        end
      end
    end
  end
end
