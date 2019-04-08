class StatsVersion < ActiveRecord::Base
  validates :process, presence: true

  belongs_to :process, polymorphic: true
end
