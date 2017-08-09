module Influx
  class InvoicePayment < ActiveRecord::Base
    include AASM

    belongs_to :plan
    belongs_to :subscription
    belongs_to :subscriber, class_name: Influx.configuration.subscriber

    validates_presence_of :email
    validates_presence_of :stripe_token
    validates_presence_of :currency
    validates_presence_of :subscriber
    validates_presence_of :subscription
    validates_presence_of :plan

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :finished
      state :errored

      event :finish, after: :instrument_finish do
        transitions from: :pending, to: :finished
      end

      event :fail, after: :instrument_fail do
        transitions from: :pending, to: :errored
      end
    end

    private

    def instrument_finish
      Influx.instrument('influx.invoice.payment.finished', self)
    end

    def instrument_fail
      Influx.instrument('influx.invoice.payment.failed', self)
    end
  end
end
