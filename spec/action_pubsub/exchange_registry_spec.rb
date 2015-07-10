require 'spec_helper'

describe ::ActionPubsub::ExchangeRegistry do
  subject { described_class.new }

  it "register_exchange" do
    subject.register_exchange("blog/posts")
    subject.key?("blog/posts").should eq true
  end
end
