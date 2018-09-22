# Influx

Subscriptions with Stripe for Rails applications. 

Influx does not contain a UI, just models and services to construct a 
subscription service.

Influx borrows heavily from the gems payola and koudoku, and especially 
the book 'Mastering Modern Payments'.

## Dependencies

Influx requires that you have:
* a subscriber model (Influx defaults to `::User`) with an `email` attribute
* Stripe keys

## Installation

To get started, add Influx to your `Gemfile` and run `bundle install` to install it:

```ruby
gem 'influx'
```

Run the influx installer and then run the migrations:

    % rails generate influx:install
    % rake db:migrate

The Influx install generator assumes your subscriber model is `::User`. You may
specify an alternate class with the `--subscriber` flag:

    % rails generate influx::install --subscriber MyApp::Profile


### What does the install task do?

* Installs and configures an initializer: `config/initializers/influx.rb`
* Add a route to mount the StripeEvent engine: `mount StripeEvent::Engine => '/hooks/stripe'`


## Configuration

The `influx::install` generator installs the Influx initializer at 
`config/initializers/influx.rb`. The initializer contains an Influx 
configuration that uses sensible defaults but offers several options.


### Subscriber class

Influx assumes your subscriber model is a class named `::User`. If you 
specify a subscriber class with the install generator, it will be set 
in the initializer's configuration:

```ruby
Influx.configure do |config|
  config.subscriber = 'MyApp::Profile'
end
```


### Stripe Keys

The default implementation expects your stripe keys to be set in three environment variables:

* `STRIPE_PUBLISHABLE_KEY`
* `STRIPE_SECRET_KEY`
* `STRIPE_SIGNING_SECRET`

It's not recommended, but you can instead set the keys yourself in the 
Influx initializer:

```ruby
Influx.configure do |config|
  config.secret_key = 'sk_test_1234567890'
  config.publishable_key = 'pk_test_1234567890'
  config.signing_secret = 'some_secret_key'
end
```


### Default Currency

The default currency defaults to 'usd'. You can change to some other currency 
with the configuration option `default_currency` in the initializer config:

```ruby
Influx.configure do |config|
  config.default_currency = 'eur'
end
```

See Stripe's [Supported Currencies](https://stripe.com/docs/currencies) page 
for more information.


### Event Processing

Influx uses the [stripe_event](https://github.com/integrallis/stripe_event) 
gem to process Stripe events. Influx records each event id and will not
process an event with the same id a second time.

You can supply an event filter in the initializer config:

```ruby
Influx.configure do |config|
  config.event_filter = MyApp::MyCustomEventFilter.new
end
```


## Usage

Influx provides models and services.

* Create plans from the console using `Influx::CreatePlan`.
* Offer subscriptions and sign users up using `Influx::CreateSubscription`.
* Change subscription plans with `Influx::ChangeSubscriptionPlan`.
* Cancel subscriptions with `Influx::CancelSubscription`.


## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/tomichj/influx. This project is intended to be a safe, 
welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
