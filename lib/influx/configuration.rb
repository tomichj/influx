module Influx
  class Configuration

    # Name of the ActiveRecord model that subscribes to plans.
    #
    # Defaults to '::User'.
    #
    # @return [String]
    attr_accessor :subscriber

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

    # Stripe signing secret.
    #
    # Defaults to ENV['STRIPE_SIGNING_SECRET']
    #
    # @return [String]
    attr_accessor :signing_secret

    # Currency you do business in.
    #
    # Defaults to 'usd'
    #
    # @return [String]
    attr_accessor :default_currency

    # The event receiver class name.
    #
    # Defaults to 'Influx::EventRetriever'
    #
    # @return [String]
    # attr_accessor :event_retriever

    # Filter Stripe events (see https://github.com/integrallis/stripe_event)
    #
    # Default filters no events.
    #
    # @return [lambda]
    attr_accessor :event_filter

    #
    # Set config defaults
    #
    def initialize
      @subscriber = '::User'
      @publishable_key = EnvWrapper.new('STRIPE_PUBLISHABLE_KEY').to_s
      @secret_key = EnvWrapper.new('STRIPE_SECRET_KEY').to_s
      @signing_secret = EnvWrapper.new('STRIPE_SIGNING_SECRET').to_s
      @default_currency = 'usd'
      @event_filter = lambda { |event| event }
    end

    # def event_retriever
    #   # @event_filter.constantize.new
    # end

    def secret_key=(key)
      @secret_key = key
      setup_stripe
    end

    # @return [Boolean] are Influx's built-in routes enabled?
    # def routes_enabled?
    #   @routes
    # end

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

    def subscribe(name, callable = Proc.new)
      ::StripeEvent.subscribe(name, callable)
    end

    def instrument(name, object)
      ::StripeEvent.backend.instrument(::StripeEvent.namespace.call(name), object)
    end

    def all(callable = Proc.new)
      ::StripeEvent.all(callable)
    end

    #
    # Read the config and plug values into Stripe and StripeEvent
    #
    def setup_stripe
      StripeEvent.event_filter = Influx::EventFilter.new
      StripeEvent.signing_secret = @signing_secret
      Stripe.api_version = ENV['STRIPE_API_VERSION'] || '2015-06-15'
      Stripe.api_key = secret_key
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

module Influx
  #
  # Record every event id as we process them.
  # Do not process an event we've already seen.
  #
  class EventFilter
    def call(event)
      return nil if Influx::StripeEvent.exists?(stripe_event_id: event.id)
      Influx::StripeEvent.create!(stripe_event_id: event.id)
      Influx.configuration.event_filter(event)
    end
  end
end
