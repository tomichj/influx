Rails.application.routes.draw do
  mount StripeEvent::Engine => '/events'
end
