require "action_pubsub/version"
require "active_support/all"
require "concurrent"
require "active_attr"

module ActionPubsub
  extend ::ActiveSupport::Autoload

  autoload :ActiveRecord
  autoload :Channel
  autoload :ChannelRegistry
  autoload :Event
  autoload :Publish
  autoload :Publishable
  autoload :Logging
  autoload :Subscriber

  class << self
    attr_accessor :configuration
    alias_method :config, :configuration

    delegate :register_channel, :to => :'::ActionPubsub::ChannelRegistry'
  end

  def self.channel_registry
    ::ActionPubsub::ChannelRegistry.channels
  end

  def self.destination(path_string)
    segs = path_string.split("/")
    action = segs.pop
    [segs.join("/"), action]
  end

  def self.symbolize_routing_key(routing_key)
    :"#{routing_key.split('.').join('_')}"
  end

  def self.publish_event(routing_key, event)
    puts "publishing_event #{routing_key}"
    channel_registry[routing_key] << event
  end
end
