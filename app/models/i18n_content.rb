class I18nContent < ActiveRecord::Base
  validates :key, uniqueness: true

  translates :value, touch: true
  globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]

  scope :debates,           -> { where("key like ?", "debates.%")}
  scope :emails,            -> { where("key like ?", "mailers.%")}
  scope :management,        -> { where("key like ?", "management.%")}
  scope :guides,            -> { where("key like ?", "guides.%")}
  scope :devise_locales,    -> { where("key like ?", "devise.%")}
  scope :devise_views,      -> { where("key like ?", "devise_views.%")}
  scope :layouts,           -> { where("key like ?", "layouts.%")}
  scope :legislation,       -> { where("key like ?", "legislation.%")}
  scope :budgets,           -> { where("key like ?", "budgets.%")}
  scope :polls,             -> { where("key like ?", "polls.%")}
  scope :proposals,         -> { where("key like ?", "proposals.%")}
  scope :community,         -> { where("key like ?", "community.%")}
end
