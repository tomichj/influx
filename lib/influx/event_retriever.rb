module Influx
  class EventRetriever
    def self.call(params)
      return nil if Influx::StripeEvent.exists?(stripe_event_id: params[:id])
      Influx::StripeEvent.create!(stripe_event_id: params[:id])

      event = Stripe::Event.retrieve(params[:id], { api_key: Influx.configuration.secret_key })
      # Payola.event_filter.call(event)
      event
    end
  end
end
