require 'spec_helper'

describe ActionPubsub do
  it 'has a version number' do
    expect(ActionPubsub::VERSION).not_to be nil
  end

  it ".exchanges" do
    described_class.exchanges.should be_a(::ActionPubsub::Registry)
  end

  it ".channels" do
    described_class.channels.should be_a(::ActionPubsub::Registry)
  end

  it ".subscriptions" do
    described_class.subscriptions.should be_a(::ActionPubsub::Registry)
  end
end
