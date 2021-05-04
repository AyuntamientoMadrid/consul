require_dependency Rails.root.join("app", "models", "proposal").to_s

Proposal.class_eval do
  scope :by_geozone_id, ->(geozone_id) { where(geozone_id: geozone_id) }

  class << self
    def allowed_filter?(filter, value)
      return if value.blank?
      %w[date_range geozone_id].include?(filter)
    end
  end
end
