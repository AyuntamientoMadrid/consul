namespace :budget_heading_supports do
  desc "Save in budget_heading_supports table the headings users have supported investments in"
  task create: :environment do
    Vote.where(votable_type: "Budget::Investment").each do |vote|
      heading = Budget::Investment.with_hidden.find(vote.votable_id).heading
      already_saved = Budget::Heading::Support.where(user: vote.voter,
                                                     budget_heading: heading).any?

      unless already_saved
        Budget::Heading::Support.create(user: vote.voter, budget_heading: heading)
      end
    end
  end
end
