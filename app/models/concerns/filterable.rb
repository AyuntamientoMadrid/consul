module Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_date_range,     ->(date_range)     { where(created_at: date_range) }
  end

  module ClassMethods

    def filter_by(params)
      resources = all
      params.each do |filter, value|
        if allowed_filter?(filter, value)
          resources = resources.send("by_#{filter}", value)
        end
      end
      resources
    end

    def allowed_filter?(filter, value)
      return if value.blank?
      ["date_range"].include?(filter)
    end

  end

end
