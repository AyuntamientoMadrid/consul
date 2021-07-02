class Audit < ApplicationRecord
    belongs_to :user, touch: true
    self.table_name = "audits"
end
