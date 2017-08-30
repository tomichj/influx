module Influx
  class Plan < ActiveRecord::Base
    has_many :subscriptions, class_name: 'Influx::Subscription'

    validates_presence_of :name
    validates_presence_of :amount
    validates_presence_of :interval
    validates_presence_of :stripe_id
    validates_uniqueness_of :stripe_id

    def create_stripe_plan
      Influx::ActivateStripePlan.call(plan: self)
    end
  end
end
