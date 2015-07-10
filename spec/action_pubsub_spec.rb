require 'spec_helper'

describe ActionPubsub do
  it 'has a version number' do
    expect(ActionPubsub::VERSION).not_to be nil
  end

  it ".exchange_registry" do
    described_class.exchange_registry.should be_a(::Concurrent::LazyRegister)
  end
end
