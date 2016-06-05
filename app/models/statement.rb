class Statement < ActiveRecord::Base
  belongs_to :audit
  attr_accessor :attachment

  validates :attachment, presence: true
  validates :audit, presence: true
end
