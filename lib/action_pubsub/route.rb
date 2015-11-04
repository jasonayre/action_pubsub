module ActionPubsub
  class Route < ::Concurrent::Actor::Utils::Balancer
    def self.inherited(subklass)
      super(subklass)
    end
  end
end
