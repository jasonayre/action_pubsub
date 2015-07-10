# ActionPubsub

In process, concurrent observers, loosely modeled after rabbitmq

## Example

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

### What is the advantage of this pattern?

The advantage is it makes your app incredibly reactive. Rather than have to fatten
up your controller with logic that does not belong, or have some service object that
does 20 things in sequence, it allows everything to be decoupled, only subscribe to
the things that are relevant. It also enforces the single responsibility principle, by
allowing these subscribers to exist in potentially different engines, or areas of your
application, and do nothing but react to the events occurring within the system.

### Callbacks

Sure, we could use callbacks, but do we care about any of that if the record has
not been commited to the database? (No we should not). Unless you use
after_commit :on => :create, then your callbacks will attempt to run even if record hasn't been committed,
unless at some point an error or false was returned.

So as a best practice, we only broadcast the creation after it's been commited.

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
