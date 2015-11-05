require 'spec_helper'

describe ::ActionPubsub::Config do
  subject { described_class.new }

  it { expect(subject.debug).to eq false }
  it { expect(subject.serializer).to be nil }
  it { expect(subject._on_error_block).to be nil }
end
