module BallotsHelper

  def added_to_ballot?(ballot, spending_proposal)
    ballot.spending_proposals.include?(spending_proposal)
  end

  def progress_bar_width(amount_available, amount_spent)
    (amount_spent / amount_available.to_f * 100).to_s + "%"
  end

  def css_for_ballot_geozone(geozone)
    return '' unless current_user.try(:ballot)
    current_user.ballot.geozone == geozone ? 'active' : ''
  end

  def district_wide_amount_spent(ballot)
    ballot.amount_spent(ballot.geozone)
  end

  def city_wide_amount_spent(ballot)
    ballot.amount_spent('all')
  end

  def remaining_votes(ballot, group)
    if group.approval_voting?
      group.number_votes_per_heading - ballot.investments.by_group(group.id).count
    else
      ballot.formatted_amount_available(ballot.heading_for_group(group))
    end
  end

end
