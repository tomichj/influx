module Influx
  class EventSubscriptionDeleted
    include Influx::Service

    def intialize(event)
      @event = event
    end

    def call
      stripe_subscription = @event.data.object
      subscription = Influx::Subscription.find_by!(stripe_id: stripe_subscription.id)
      subscription.cancel! if subscription.may_cancel?
    end
  end
end
