class Migrations::SpendingProposal::Vote
  include Migrations::Log

  def migrate_delegated_votes
    delegated_votes.each do |delegated_vote|
      create_vote(delegated_vote)
    end
  end

  def create_vote(delegated_vote)
    vote_attributes = {
      voter: delegated_vote[:voter],
      votable: delegated_vote[:votable],
      delegated: true
    }
    Vote.create!(vote_attributes)
    log(".")
  end

  def delegated_votes
    representative_votes.map do |vote|
      represented_user_votes(vote)
    end.flatten
  end

  def representative_votes
    Vote.representative_votes
  end

  def represented_user_votes(vote)
    representative = vote.voter.forum
    spending_proposal = vote.votable

    representative.represented_users.map do |represented_user|
      represented_user_vote(represented_user, spending_proposal)
    end.compact
  end

  def represented_user_vote(represented_user, spending_proposal)
    unless represented_user.voted_for?(spending_proposal)
      { voter: represented_user,
        votable: spending_proposal }
    end
  end

  def create_budget_investment_votes
    spending_proposal_votes.each do |vote|
      create_budget_invesment_vote(vote)
      log(".")
    end
  end

  private

    def spending_proposal_votes
      Vote.where(votable: SpendingProposal.all)
    end

    def create_budget_invesment_vote(vote)
      budget_investment = find_budget_investment(vote.votable)
      if budget_investment
        budget_investment.vote_by(voter: vote.voter, vote: "yes")
      end
    end

    def find_budget_investment(spending_proposal)
      Budget::Investment.where(original_spending_proposal_id: spending_proposal.id).first
    end

end
