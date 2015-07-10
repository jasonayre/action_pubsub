$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'action_pubsub'

require 'bundler'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before(:suite) do
  end
end

Bundler.require(:default, :development, :test)

::Dir["#{::File.dirname(__FILE__)}/support/*.rb"].each {|f| require f }
