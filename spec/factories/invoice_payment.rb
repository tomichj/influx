FactoryBot.define do
  factory :invoice_payment, class: 'Influx::InvoicePayment' do
    association :subscription
    association :subscriber
    association :plan

    uuid  'fake-uuid'
    email 'foo@bar.com'
    stripe_id 'inv_12345'

    amount 5000
    fee_amount 0
    currency 'usd'
    # state 'CA'

    card_last4 '1234'
    card_expiration  Time.now + 7.days
    card_type 'MASTERCARD'
    # error
  end
end
