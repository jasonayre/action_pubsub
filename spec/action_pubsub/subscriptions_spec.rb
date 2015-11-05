require 'spec_helper'
require 'concurrent'
require 'concurrent/atomics'
require 'concurrent/atomic/atomic_reference'
describe ::ActionPubsub::Subscriptions do

  before(:all) do
    ::ActionPubsub.on('blog/comment/created', :as => 'one') do |record|
    end

    ::ActionPubsub.on('blog/comment/created', :as => 'two') do |record|
    end
  end

  subject { ::ActionPubsub.subscriptions }

  it { expect(subject.key?('blog/comment/created:one')).to eq true }
  it { expect(subject.key?('blog/comment/created:two')).to eq true }
end
