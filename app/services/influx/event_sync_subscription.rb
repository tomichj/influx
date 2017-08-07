module Influx
  class EventSyncSubscription
    include Influx::Service

    def initialize(event:)
      @event = event
    end

    def call
      stripe_subscription = @event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.sync_with!(stripe_subscription)
    end
  end
end
