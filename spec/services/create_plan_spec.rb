require 'spec_helper'

module Influx
  module Services
    describe CreatePlan do
      describe '#call' do
        it 'creates a plan' do
          params = attributes_for(:plan)
          plan   = Influx::Services::CreatePlan.call(params)
          expect(plan.name).to eq params[:name]
          expect(plan.amount).to eq params[:amount]
          expect(plan.stripe_id).to eq params[:stripe_id]
          expect(plan.interval).to eq params[:interval]
          expect(plan.interval_count).to eq params[:interval_count]
          expect(plan.trial_period_days).to eq params[:trial_period_days]
        end

        context 'stripe failure' do
          it 'sets error on plan' do

          end
        end
      end
    end
  end
end
