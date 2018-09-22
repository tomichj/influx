module Influx
  class Plan < ActiveRecord::Base
    has_many :subscriptions, class_name: 'Influx::Subscription', foreign_key: :influx_plan_id

    validates_presence_of :name
    validates_presence_of :amount
    validates_presence_of :interval
    validates_presence_of :stripe_id
    validates_uniqueness_of :stripe_id

    scope :published, -> { where(published: true) }

    def create_stripe_plan
      Influx::Services::ActivateStripePlan.call(plan: self)
    end
  end
end
