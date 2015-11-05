require 'spec_helper'

describe ::ActionPubsub::Exchanges do
  subject do
    exchanges = described_class.new
    exchanges.register_exchange("blog/posts")
    exchanges
  end

  describe "#register_exchange" do
    it { expect(subject.key?("blog/posts")).to eq true }
    it { expect(subject["blog/posts"]).to be_a(described_class) }
  end
end
