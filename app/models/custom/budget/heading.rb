require_dependency Rails.root.join("app", "models", "budget", "heading").to_s

Budget::Heading.class_eval do
  class << self
    alias_method :consul_sort_by_name, :sort_by_name

    def sort_by_name
      consul_sort_by_name.partition(&:city_heading?).flatten
    end
  end
end
