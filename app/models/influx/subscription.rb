module Influx
  class Subscription < ActiveRecord::Base
    belongs_to :plan
    belongs_to Influx.configuration.subscriber_singular
  end
end
