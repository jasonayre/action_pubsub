require 'spec_helper'

describe ::ActionPubsub::Channels do
  subject {
    channels = described_class.new
    channels['some/channel']
    channels
  }

  it { expect(subject['some/channel']).to be_a(::Concurrent::Actor::Reference) }
  it { expect(subject['some/channel'].name).to eq 'some/channel' }
end
