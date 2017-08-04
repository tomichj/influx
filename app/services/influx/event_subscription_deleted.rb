module Influx
  class EventSubscriptionDeleted
    def self.call(event)
      stripe_subscription = event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.cancel! if subscription.may_cancel?
    end
  end
end
