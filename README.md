# ActionPubsub

In process, concurrent observers, loosely modeled after rabbitmq

## Active Record Example

Lets say we have a blog app, and our posts have comments enabled on a case by case basis.
When someone leaves a new comment, we want to blast out an email to everyone who
has subscribed to recieve new posts

In our comments model:

``` ruby
module Blogger
  class Comment < ::ActiveRecord::Base
    include ::ActionPubsub::ActiveRecord::Publishable
    publish_as "blogger/comment"
    publishable_actions :created, :updated
  end
end
```

Our subscriber:
``` ruby
module Blogger
  class CommentSubscriber < ::ActionPubsub::ActiveRecord::Subscriber
    #this is the "exchange" we want all of the events we are watching for, to be scoped to
    #i.e. blogger/comment/created will end up being the fully qualified path for on :create
    subscribe_to "blogger/comment"

    self.concurrency = 5

    on :created, :if => lambda{ |record| record.post.has_comments_enabled? } do
      #on initialize right now subscriber instance will get a resource instance variable
      #populated for free pertaining to the record in focus, i.e. a comment record
      resource.post.commenters.by_new_comment_notifications_enabled.each do |commenter|
        NewCommentNotificationMailer.deliver(resource, commenter)
      end
    end
  end
end
```

## Non Active Record Subscribers

As of 0.2.0, we can make anything subscribable, and publish to specific non "exchange" queues.

``` ruby
module Blogger
  class Comment < ::ActiveRecord::Base
    after_create :publish_after_create, :publish_after_save

    def publish_after_create
      ::ActionPubsub.publish('blogger/comment/created')
    end

    def publish_after_save
      ::ActionPubsub.publish('blogger/comment/saved')
    end    
  end
end
```

``` ruby
class CommentSentimentAnalyzer
  include ::ActionPubsub::HasSubscriptions
  include ::ActionPubsub::ActiveRecord::WithConnection

  class_attribute :sentiment_scores
  self.sentiment_scores = []

  on 'blogger/comment/created' do |record|
    result = perform_sentiment_analysis(record)

    if(result.is_beligerent?)
      record.status = :hidden
      record.sentiment_score = result.value
    else
      record.sentiment_score = result.value
    end

    self.class.sentiment_scores << record.sentiment_score

    record.save
  end

  def perform_sentiment_analysis(record)
    ##hit some 3rd party sentiment analysis api
    return record
  end

  def average_sentiment
    sentiment_scores.calculate_average
  end
end
```

Notes:
1. The cool thing about the above, is not only is it a really lean, loosely coupled subscription, but its subscribes *asynchronously*, so we can call the 3rd party sentiment analysis api
directly from our subscriber without worrying about blocking the main thread.

2. the use of
``` ruby
include ::ActionPubsub::ActiveRecord::WithConnection
```

This ensures that the active record connection gets checked out and checked back into the pool, else youll run out of connections quickly. If you are not doing anything with active record, dont include it. If you are doing ANYTHING with active record (running a query or anything), make sure to include it, or wrap every on action in a connection checkout block, i.e.

``` ruby
::ActiveRecord::Base.connection_pool.with_connection
```

### Alternative Methods of Publish/Subscription

``` ruby
::ActionPubsub.publish('blogger/comment/created', {:my => :comment})

#accessing and publishing to the channel directly
::ActionPubsub['blogger/comment/created'] << {:my => :comment}

#subscribing to channel directly
::ActionPubsub.on('blogger/comment/created') do |comment|
  puts comment.inspect
end

#multiple subscriptions per channel are allowed as well
::ActionPubsub.on('blogger/comment/created') do |comment|
  puts "do something else with comment #{comment}"
end

#as well as unique keyed subscriptions by name, i.e.
::ActionPubsub.on('blogger/comment/created', :as => '/user/1/blogger/comment/created') do |comment|
  puts "do something specific to user 1 with comment"
end

#will ensure that the existing subscription does not get duplicated.
```

### What is the advantage of this pattern?

The advantage is it makes your app incredibly reactive. Rather than have to fatten
up your controller with logic that does not belong, or have some service object that
does 20 things in sequence, it allows everything to be decoupled, only subscribe to
the things that are relevant. It also enforces the single responsibility principle, by
allowing these subscribers to exist in potentially different engines, or areas of your
application, and do nothing but react to the events occurring within the system.

### Callbacks

The ActiveRecord callbacks from the ActionPubsub::ActiveRecord module, are only fired after_commit.
If for some reason that's a problem, you probably don't want a subscriber to begin with,
and should stick with standard callbacks. Meaning, subscribers are primarily intended to perform duties
relevant to the model, but that do not change the model itself.

This also allows for complex chains of events to occur, with no knowledge of each other,
but that do their one job, and do it well. If that subscriber happens to create a new record,
We can then subscribe to that models creation somewhere else, settings up the building blocks of a pipeline.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_pubsub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_pubsub

## Usage

TODO: Work in progress

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/action_pubsub.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
