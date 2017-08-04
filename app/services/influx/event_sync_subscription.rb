module Influx
  class EventSyncSubscription
    def self.call(event)
      stripe_subscription = event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.sync_with!(stripe_subscription)
    end
  end
end
