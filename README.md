# Influx

Subscriptions with Stripe for Rails applications. 

Influx does not contain a UI, just models and services to construct a subscription service.

Influx borrows heavily from payola, koudoku, and especially the book 'Mastering Modern Payments'.

## Dependencies

Influx 


## Installation

To get started, add Influx to your `Gemfile` and run `bundle install` to install it:

```ruby
gem 'influx'
```

Run the installer and then the migrations:

    $ rails generate influx:install
    $ rake db:migrate

The Influx install generator assumes your subscriber model is `::User`. You may specify an alternate class with the
`--subscriber` flag:

    $ rails generate influx::install --subscriber MyApp::Profile


## Configuration

The `influx::install` generator installs the Influx initializer at `config/initializers/influx.rb`. The initializer
contains an Influx configuration that uses sensible defaults but offers several options.

### Subscriber class

Influx assumes your subscriber model is a class named `::User`. If you specify a subscriber class with the install
generator, it will be set in the initializer's configuration:

```ruby
Influx.configure do |config|
  config.subscriber = 'MyApp::Profile'
end
```


### Stripe Keys

The default configuration reads Stripe keys from the environment, via `ENV['STRIPE_SECRET_KEY']` and 
`ENV['STRIPE_PUBLISHABLE_KEY']`. Set your keys in your environment before starting rails. 

It's not recommended, but you can instead set the keys yourself in the Influx initializer:

```ruby
Influx.configure do |config|
  config.secret_key = 'sk_test_1234567890'
  config.publishable_key = 'pk_test_1234567890'
end
```


### Default Currency

The default currency defaults to 'usd'. You can change to some other currency with the configuration
option `default_currency` in the initializer config:

```ruby
Influx.configure do |config|
  config.default_currency = 'eur'
end
```

See Stripe's [Supported Currencies](https://stripe.com/docs/currencies) page for more information.


### Event Retriever

Influx uses the [stripe_event](https://github.com/integrallis/stripe_event) gem to retrieve Stripe events.
Influx ships with an EventRetriever implementation that records all events seen and will not retrieve an event
with the same id a second time.

You can specify your own event retriever in the initializer config:

```ruby
Influx.configure do |config|
  config.event_retriever = 'MyApp::MyCustomEventRetriever'
end
```


## Usage

Influx primarily provides models and services.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/influx. This project 
is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

