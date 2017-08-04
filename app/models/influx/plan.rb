module Influx
  class Plan < ActiveRecord::Base
    validates_presence_of :amount
    validates_presence_of :interval
    validates_presence_of :stripe_id
    validates_presence_of :name

    validates_uniqueness_of :stripe_id

    has_many :subscriptions, class_name: 'Influx::Subscription'

    def create_stripe_plan
      Influx::CreateStripePlan.call(self)
    end
  end
end
