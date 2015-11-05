require 'spec_helper'

describe ActionPubsub do
  before(:all) do
    @messages_received = ::Concurrent::AtomicReference.new
    @messages_received.update{ |_set| [] }

    ::ActionPubsub.on('blog/post/created', :as => 'one') do |record|
      @messages_received.update{|_set|
        _set << record
        _set
      }
    end

    ::ActionPubsub.on('blog/post/created', :as => 'two') do |record|
      @messages_received.update{|_set|
        _set << record
        _set
      }
    end
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

  context "publishing" do
    #todo: hmmm i thought atomic reference blocked?

    it do
      ::ActionPubsub.publish('blog/post/created', :publishing_test_blog_post_created)
      sleep(0.1)
      expect(@messages_received.get).to include(:publishing_test_blog_post_created)
    end

    context "each subscriber receives one copy of the message" do
      it do
        ::ActionPubsub.publish('blog/post/created', :publishing_test_blog_post_created_copy)
        sleep(0.1)
        expect(@messages_received.get.select{|item| item == :publishing_test_blog_post_created_copy}.length).to eq 2
      end
    end

    context "duplicate subscribers dont spawn new subscribers" do
      before(:all) do
        ::ActionPubsub.on('blog/post/created', :as => 'one') do |record|
          @messages_received.update{|_set|
            _set << record
            _set
          }
        end
      end

      it do
        ::ActionPubsub.publish('blog/post/created', :publishing_test_blog_post_created_copy_again)
        sleep(0.1)
        expect(@messages_received.get.select{|item| item == :publishing_test_blog_post_created_copy_again}.length).to eq 2
      end
    end
  end
end
