require 'spec_helper'
require 'influx/configuration'

module Influx
  describe Configuration do
    # it 'provides an event retriever' do
    #   expect(Configuration.new.event_retriever).to_not be_nil
    # end

    describe 'subscriber' do
      before(:each) do
        @conf = Configuration.new
        @conf.subscriber = 'Gug::Profile'
      end

      it 'gets a class for subscriber' do
        expect(@conf.subscriber_class).to be(Gug::Profile)
      end

      it 'gets a singular key' do
        expect(@conf.subscriber_singular).to eq 'gug_profile'
      end

      it 'gets a plural key' do
        expect(@conf.subscriber_plural).to eq 'gug_profiles'
      end
    end

    describe 'stripe keys' do
      it 'sets publishable key from env' do
        ENV['STRIPE_PUBLISHABLE_KEY'] = 'public_key'
        expect(Configuration.new.publishable_key).to eq 'public_key'
      end

      it 'sets secret key from env' do
        ENV['STRIPE_SECRET_KEY'] = 'secret_key'
        expect(Configuration.new.secret_key).to eq 'secret_key'
      end
    end

    describe 'instrumentation' do
      it 'passes subscribe to StripeEvent' do
        expect(StripeEvent).to receive(:subscribe)
        Configuration.new.subscribe('foo', 'bar')
      end
      it 'passes instrument to StripeEvent.backend' do
        expect(ActiveSupport::Notifications).to receive(:instrument)
        Configuration.new.instrument('foo', 'bar')
      end
      it 'passes all to StripeEvent' do
        expect(StripeEvent).to receive(:all)
        Configuration.new.all('blah')
      end
    end
  end
end


module Gug
  # Faux user model
  class Profile
    extend ActiveModel::Naming
  end
end

