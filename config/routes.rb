if Influx.configuration.routes_enabled?
  Rails.application.routes.draw do
    # match 'subscribe' => 'subscriptions#create', via: :post


    mount StripeEvent::Engine => '/events'
  end
end
