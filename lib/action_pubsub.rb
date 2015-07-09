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
  autoload :Event
  autoload :Exchange
  autoload :ExchangeRegistry
  autoload :Publish
  autoload :Publishable
  autoload :Logging
  autoload :Subscriber
  autoload :Queue

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

  def self.symbolize_routing_key(routing_key)
    :"#{routing_key.split('.').join('_')}"
  end

  def self.publish_event(routing_key, event)
    #need to loop through exchanges and publish to them
    #maybe there is a better way to do this?
    exchange_hash = ::ActionPubsub.exchanges[routing_key].instance_variable_get("@data").value
    queue_names = exchange_hash.keys
    queue_names.each do |queue_name|
      exchange_registry[routing_key][queue_name] << event
    end
  end

  class << self
    attr_accessor :configuration
    alias_method :config, :configuration
    alias_method :exchanges, :exchange_registry

    delegate :register_queue, :to => :exchange_registry
    delegate :register_channel, :to => :exchange_registry
    delegate :register_exchange, :to => :exchange_registry
  end
end
