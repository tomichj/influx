module Influx
  class EventRetriever
    def call(params)
      return nil if Influx::StripeEvent.exists?(stripe_event_id: params[:id])
      Influx::StripeEvent.create!(stripe_event_id: params[:id])
      Stripe::Event.retrieve(params[:id], { api_key: Influx.configuration.secret_key })
    end
  end
end
