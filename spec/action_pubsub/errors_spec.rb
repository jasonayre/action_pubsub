require 'spec_helper'

describe ::ActionPubsub::Errors do
  subject { described_class.new }

  context 'SubscriptionReactionErrorMessage' do
    let(:error) { {:message => "whatev"}}
    let(:message) { {:what => :up} }
    subject { ::ActionPubsub::Errors::SubscriptionReactionErrorMessage.new(:message => message, :error => error ) }
    it { expect(subject.message[:what]).to eq :up }
    it { expect(subject.error[:message]).to eq "whatev" }
  end
end
