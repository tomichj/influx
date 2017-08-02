module Influx
  # Record stripe events.
  #
  # Prevent accidental or intentional double-submission of events (replay attacks, etc)
  # by ensuring events are unique and processed only once.
  class StripeEvent < ActiveRecord::Base
    validates_uniqueness_of :stripe_event_id
  end
end
