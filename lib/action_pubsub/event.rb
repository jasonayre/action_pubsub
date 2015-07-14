require 'active_model'

module ActionPubsub
  class Event
    include ::ActiveAttr::Model
    include ::ActiveModel::AttributeMethods

    attribute :id
    attribute :action
    attribute :context
    attribute :meta
    attribute :name
    attribute :occured_at
    attribute :record
    attribute :subject
    attribute :topic

    #attributes have to be set for purposes of marshaling
    def initialize(topic:, record:nil, context: nil, **options)
      self[:topic] = topic
      self[:action] = topic.split("/").pop.to_sym
      self[:meta] = options[:meta] || {}
      self[:name] = topic
      self[:record] = record
      self[:id] = ::SecureRandom.hex
      self[:subject] = options[:subject] || record.try(:class).try(:name)
      self[:context] = context if context
      self[:occured_at] ||= ::Time.now.to_i
    end
  end
end
