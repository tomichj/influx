module Influx
  class Configuration

    # Name of the ActiveRecord model that subscribes to plans.
    #
    # Defaults to '::User'.
    #
    # @return [String]
    attr_accessor :subscriber

    # Enable or disable Influx's built-in routes.
    #
    # Defaults to 'true'.
    #
    # If you disable the routes, your application is responsible for all routes.
    #
    # You can deploy a copy of Influx's routes with `rails generate influx:routes`,
    # which will also set `config.routes = false`.
    #
    # @return [Boolean]
    attr_accessor :routes

    # Stripe secret key.
    #
    # Defaults to ENV['STRIPE_SECRET_KEY']
    #
    # @return [String]
    attr_accessor :secret_key

    # Stripe publishable key.
    #
    # Defaults to ENV['STRIPE_PUBLISHABLE_KEY']
    #
    # @return [String]
    attr_accessor :publishable_key

    # The 'from' address in emails from your system.
    #
    # Defaults to 'sales@example.com'
    #
    # @return [String]
    attr_accessor :support_email

    # Currency you do business in.
    #
    # Defaults to 'usd'
    #
    # @return [String]
    attr_accessor :default_currency

    def initialize
      @subscriber = '::User'
      @routes = true
      @publishable_key = EnvWrapper.new('STRIPE_PUBLISHABLE_KEY')
      @secret_key = EnvWrapper.new('STRIPE_SECRET_KEY')
      @support_email = 'sales@example.com'
      @default_currency = 'usd'
    end

    def setup_stripe
      Stripe.api_version = ENV['STRIPE_API_VERSION'] || '2015-06-15'
      Stripe.api_key = secret_key
    end

    def secret_key=(key)
      @secret_key = key
      setup_stripe
    end

    # @return [Boolean] are Influx's built-in routes enabled?
    def routes_enabled?
      @routes
    end

    # The subscriber model's class.
    #
    # @return [ActiveRecord::Base]
    def subscriber_class
      @subscriber_class ||=
        if @subscriber.respond_to?(:constantize)
          @subscriber.constantize
        else
          @subscriber
        end
    end

    def subscriber_singular
      subscriber_class.model_name.singular
    end

    def subscriber_plural
      subscriber_class.model_name.plural
    end


    # Subscribe to a stripe event.
    #
    def subscribe(name, callable = Proc.new)
      StripeEvent.subscribe(name, callable)
    end

    def instrument(name, object)
      StripeEvent.backend.instrument(StripeEvent.namespace.call(name), object)
    end

    def all(callable = Proc.new)
      StripeEvent.all(callable)
    end
  end


  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
    configuration.setup_stripe
  end

  def self.configure
    yield configuration
    configuration.setup_stripe
  end
end


class EnvWrapper
  def initialize(key)
    @key = key
  end

  def to_s
    ENV[@key]
  end

  def ==(other)
    to_s == other.to_s
  end

  # This is a nasty hack to counteract Stripe checking if the API key is_a String
  # See https://github.com/peterkeen/payola/issues/256 for details
  def is_a?(other)
    ENV[@key].is_a?(other)
  end
end