class Budget
  class Group < ApplicationRecord
    include Sluggable

    translates :name, touch: true
    include Globalizable
    translation_class_delegate :budget

    class Translation
      validate :name_uniqueness_by_budget
      before_save :strip_name

      def name_uniqueness_by_budget
        if budget.groups.joins(:translations)
                        .where(name: name)
                        .where.not("budget_group_translations.budget_group_id": budget_group_id).any?
          errors.add(:name, I18n.t("errors.messages.taken"))
        end
      end

      private

        def strip_name
          name.strip!
        end
    end

    belongs_to :budget

    has_many :headings, dependent: :destroy

    before_validation :assign_model_to_translations

    validates_translation :name, presence: true
    validates :budget_id, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :max_votable_headings, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :max_supportable_headings, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

    scope :by_slug, ->(slug) { where(slug: slug) }
    scope :sort_by_name, -> { joins(:translations).order(:name) }

    def to_param
      slug
    end

    scope :sort_by_name, -> { includes(:translations).order(:name) }

    def single_heading_group?
      headings.count == 1
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end
  end
end
