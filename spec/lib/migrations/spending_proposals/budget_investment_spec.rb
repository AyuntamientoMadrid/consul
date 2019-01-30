require "rails_helper"
require "migrations/spending_proposal/budget_investment"

describe Migrations::SpendingProposal::BudgetInvestment do

  let!(:budget)            { create(:budget, slug: "2016") }

  let!(:spending_proposal) { create(:spending_proposal) }

  let!(:budget_investment) { create(:budget_investment,
                                     budget: budget,
                                     original_spending_proposal_id: spending_proposal.id) }

  describe "#initialize" do

    it "initializes the spending proposal and corresponding budget investment" do
      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)

      expect(migration.spending_proposal).to eq(spending_proposal)
      expect(migration.budget_investment).to eq(budget_investment)
    end

  end

  describe "#update" do

    it "updates the attribute unfeasibility_explanation" do
      explanation = "This project is not feasible because it is too expensive"
      spending_proposal.update(feasible_explanation: explanation)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload

      expect(budget_investment.unfeasibility_explanation).to eq(explanation)
    end

  end

end
