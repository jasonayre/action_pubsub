require 'spec_helper'

describe ::ActionPubsub::Types do
  subject { described_class.new }

  context 'SubscriptionReactionError' do
    let(:error) { {:message => "whatev"}}
    let(:message) { {:what => :up} }
    subject { ::ActionPubsub::Types::SubscriptionReactionError.new(:message => message, :error => error ) }
    it { expect(subject.message[:what]).to eq :up }
    it { expect(subject.error[:message]).to eq "whatev" }
  end
end
