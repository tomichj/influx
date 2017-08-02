module Influx

  # Stripe event.
  #
  # Prevent accidental or intentional double-submission of events (replay attacks, etc)
  # by tracking each stripe event processed, ensuring events are unique and processed only once.
  #
  class StripeEvent < ActiveRecord::Base
    validates_uniqueness_of :stripe_event_id
  end
end
