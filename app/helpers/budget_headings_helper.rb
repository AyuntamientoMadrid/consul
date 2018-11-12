module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    budget.headings.order_by_group_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end

  def heading_link(assigned_heading = nil, budget = nil)
    return nil unless assigned_heading && budget
    heading_path = budget_investments_path(budget, heading_id: assigned_heading.try(:id))
    link_to(assigned_heading.name, heading_path)
  end

  def current_heading_map_locations(investments)
    investments.map do |investment|
      next unless investment.map_location.present?
      {
        lat: investment.map_location.latitude,
        long: investment.map_location.longitude,
        investment_title: investment.title,
        investment_id: investment.id,
        budget_id: investment.budget.id
      }
    end.flatten.compact
  end

end
