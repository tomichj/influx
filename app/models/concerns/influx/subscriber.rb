module Influx
  module Subscriber
    extend ActiveSupport::Concern
    included do
      has_many :subscriptions, class_name: 'Influx::Subscription', foreign_key: 'subscriber_id'
    end
  end
end
