module ActionPubsub
  class Channels < ::ActionPubsub::Registry
    def [](val)
      return super(val) if key?(val)

      add(val){ ::ActionPubsub::Channel.spawn(val) }
      super(val)
    end
  end
end
