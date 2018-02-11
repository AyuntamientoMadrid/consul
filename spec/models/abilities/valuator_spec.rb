require 'rails_helper'
require 'cancan/matchers'

describe Abilities::Valuator do
  subject(:ability) { Ability.new(user) }

  let(:user) { valuator.user }
  let(:valuator) { create(:valuator) }
  let(:group) { create(:valuator_group) }
  let(:non_assigned_investment) { create(:budget_investment) }
  let(:assigned_investment) { create(:budget_investment, budget: create(:budget, phase: 'valuating')) }
  let(:group_assigned_investment) { create(:budget_investment, budget: create(:budget, phase: 'valuating')) }
  let(:finished_assigned_investment) { create(:budget_investment, budget: create(:budget, phase: 'finished')) }

  before do
    assigned_investment.valuators << valuator

    group_assigned_investment.valuator_groups << group
    valuator.update(valuator_group: group)

    finished_assigned_investment.valuators << valuator
  end

  it { should be_able_to(:read, SpendingProposal) }

  describe "valuation open" do

    before(:each) do
      Setting['feature.spending_proposal_features.valuation_allowed'] = true
    end

    it { should be_able_to(:update, SpendingProposal) }
    it { should be_able_to(:valuate, SpendingProposal) }
  end

  describe "valuation finished" do

    before(:each) do
      Setting['feature.spending_proposal_features.valuation_allowed'] = nil
    end

    it { should_not be_able_to(:update, SpendingProposal) }
    it { should_not be_able_to(:valuate, SpendingProposal) }
  end

  it { should_not be_able_to(:update, non_assigned_investment) }
  it { should_not be_able_to(:valuate, non_assigned_investment) }

  it { should be_able_to(:update, assigned_investment) }
  it { should be_able_to(:valuate, assigned_investment) }

  it { should be_able_to(:update, group_assigned_investment) }
  it { should be_able_to(:valuate, group_assigned_investment) }

  it { should_not be_able_to(:update, finished_assigned_investment) }
  it { should_not be_able_to(:valuate, finished_assigned_investment) }

end
