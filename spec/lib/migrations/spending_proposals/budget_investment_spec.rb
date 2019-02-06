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

    it "uses the price explanation attribute if unfeasibility explanation is not present" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.price_explanation = "price explanation saying it is too expensive"

      spending_proposal.feasible = false
      spending_proposal.valuation_finished = true

      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("price explanation saying it is too expensive")
    end

    it "uses the internal comments if unfeasibility explanation is not present" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.internal_comments = "Internal comment with explanation"

      spending_proposal.feasible = false
      spending_proposal.valuation_finished = true

      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("Internal comment with explanation")
    end

    it "does not use other attributes if investment is feasible" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.price_explanation = "price explanation saying it is too expensive"

      spending_proposal.feasible = true
      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("")
    end

    it "gracefully handles missing corresponding budget investment" do
      budget_investment.destroy

      expect{ migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal);
              migration.update }
      .not_to raise_error
    end

  end

end
