require 'spec_helper'

describe ActionPubsub do
  it 'has a version number' do
    expect(ActionPubsub::VERSION).not_to be nil
  end

  it ".channel_registry" do
    described_class.channel_registry.should be_a(::Concurrent::LazyRegister)
  end
end
