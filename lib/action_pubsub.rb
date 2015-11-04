require "action_pubsub/version"
require "active_support/all"
require "concurrent"
require "active_attr"
require "concurrent/lazy_register"
require "concurrent/actor"
require "concurrent/agent"

module ActionPubsub
  extend ::ActiveSupport::Autoload

  autoload :ActiveRecord
  autoload :Config
  autoload :Channel
  autoload :Channels
  autoload :Errors
  autoload :Event
  autoload :Exchange
  autoload :ExchangeRegistry
  autoload :HasSubscriptions
  autoload :Publish
  autoload :Publishable
  autoload :Logging
  autoload :Subscriber
  autoload :Subscriptions
  autoload :Registry
  autoload :Routes
  autoload :Route
  autoload :Queue

  @configuration ||= ::ActionPubsub::Config.new

  def self.configure(&block)
    block.call(config)
  end

  def self.channels
    @channels ||= ::ActionPubsub::Channels.new
  end

  def self.channel?(channel_path)
    channels.key?(channel_path)
  end

  def self.event_count
    @event_count ||= ::Concurrent::Agent.new(0)
  end

  def self.exchange_registry
    @exchange_registry ||= ::ActionPubsub::ExchangeRegistry.new
  end

  def self.destination_tuple_from_path(path_string)
    segs = path_string.split("/")
    worker_index = segs.pop
    action = segs.pop

    [segs.join("/"), action, worker_index]
  end

  def self.destination_tuple_from_sender_path(path_string)
    segs = path_string.split("/")
    action = segs.pop
    [segs.join("/"), action]
  end

  def self.on(*paths, as:nil, &block)
    paths.map do |path|
      target_channel = ::ActionPubsub.channels[path]
      subscription_path = "#{path}:#{as || SecureRandom.uuid}"

      ::ActionPubsub.subscriptions[subscription_path] = ::Concurrent::Actor::Utils::AdHoc.spawn(subscription_path) do
        target_channel << :subscribe
        -> message {
          block.call(message)
        }
      end
    end
  end

  def self.symbolize_routing_key(routing_key)
    :"#{routing_key.split('.').join('_')}"
  end

  def self.publish(path, message)
    self[path] << message
  end

  def self.publish_event(routing_key, event)
    #need to loop through exchanges and publish to them
    #maybe there is a better way to do this?
    ::ActionPubsub.exchanges[routing_key].keys.each do |queue_name|
      exchange_registry[routing_key][queue_name] << serialize_event(event)
    end
  end

  def self.serialize_event(event)
    event
  end

  def self.subscriptions
    @subscriptions ||= ::ActionPubsub::Subscriptions.new
  end

  def self.subscription?(path)
    subscriptions.key?(path)
  end

  def self.deserialize_event(event)
    event
  end

  class << self
    attr_accessor :configuration
    alias_method :config, :configuration
    alias_method :exchanges, :exchange_registry

    delegate :[], :to => :channels
    delegate :register_queue, :to => :exchange_registry
    delegate :register_channel, :to => :exchange_registry
    delegate :register_exchange, :to => :exchange_registry
  end
end
