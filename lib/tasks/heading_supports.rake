namespace :budget_heading_supports do
  desc "Save in budget_heading_supports table the headings users have supported investments in"
  task create: :environment do
    Budget::Heading.pluck(:id).each do |heading_id|
      voters = Vote.joins("JOIN budget_investments ON budget_investments.id = votes.votable_id")
                   .where(votable_type: "Budget::Investment")
                   .where("budget_investments.heading_id = ?", heading_id)
                   .pluck(:voter_id)
      voters.uniq.each do |voter_id|
        Budget::Heading::Support.create(user_id: voter_id, budget_heading_id: heading_id)
      end
    end
  end
end
