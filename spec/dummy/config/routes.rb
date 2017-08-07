Rails.application.routes.draw do

  mount Influx::Engine => "/influx", as: :influx
end
