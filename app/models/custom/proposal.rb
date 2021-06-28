require_dependency Rails.root.join("app", "models", "proposal").to_s

Proposal.class_eval do
  scope :by_geozone_id, ->(geozone_id) { where(geozone_id: geozone_id) }
  scope :sort_by_oldest, -> { reorder(:created_at) }

  class << self
    alias_method :consul_proposals_orders, :proposals_orders

    def allowed_filter?(filter, value)
      return if value.blank?
      %w[date_range geozone_id].include?(filter)
    end

    def proposals_orders(user)
      consul_proposals_orders(user) << "oldest"
    end
  end
end
