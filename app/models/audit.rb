class Audit < ActiveRecord::Base
  has_many :statements

  validates :name, presence: true
end
