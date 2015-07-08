module ActionPubsub
  class ChannelRegistry
    class_attribute :channels

    self.channels = ::Concurrent::LazyRegister.new

    def self.register_channel(channel_name)
      channels.add(channel_name) { ::ActionPubsub::Channel.spawn(channel_name) }
    end
  end
end
