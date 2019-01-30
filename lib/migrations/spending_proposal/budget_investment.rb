class Migrations::SpendingProposal::BudgetInvestment
  attr_accessor :spending_proposal, :budget_investment

  def initialize(spending_proposal)
    @spending_proposal = spending_proposal
    @budget_investment = find_or_initialize_budget_investment
  end

  def update
    if budget_investment && budget_investment.update(budget_investment_attributes)
      print "."
    else
      puts "Error updating budget investment from spending proposal: #{spending_proposal.id}\n"
    end
  end

  private

    def budget
      Budget.where(slug: "2016").first
    end

    def find_or_initialize_budget_investment
      budget.investments.where(original_spending_proposal_id: spending_proposal.id).first
    end

    def budget_investment_attributes
      { unfeasibility_explanation: field_with_unfeasibility_explanation }
    end

    def field_with_unfeasibility_explanation
      if spending_proposal.unfeasible?
        spending_proposal.feasible_explanation.presence ||
        spending_proposal.price_explanation.presence ||
        spending_proposal.internal_comments
      else
        spending_proposal.feasible_explanation
      end
    end

end
