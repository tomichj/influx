require 'aasm'

module Influx
  class InvoicePayment < ActiveRecord::Base
    include AASM

    belongs_to :plan
    belongs_to :subscription
    belongs_to :subscriber, class_name: Influx.configuration.subscriber
    scope :most_recent, -> { order('created_at desc').limit(1).first }

    validates_presence_of :email
    validates_presence_of :stripe_id
    validates_presence_of :currency
    validates_presence_of :subscriber
    validates_presence_of :subscription
    validates_presence_of :plan

    aasm column: 'state' do
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
      Influx.configuration.instrument('influx.invoice.payment.finished', self)
      # Rails.logger.info "instrument invoice finish, StripeEvent:" + StripeEvent.inspect
    end

    def instrument_fail
      Influx.configuration.instrument('influx.invoice.payment.failed', self)
    end
  end
end
