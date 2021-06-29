class Complan::Project < ApplicationRecord
    belongs_to :complan_strategy, class_name: "Complan::Strategy", foreign_key: "complan_strategy_id"
    has_many :complan_performances, foreign_key: "complan_project_id", class_name: "Complan::Performance", dependent: :destroy


    self.table_name = "complan_projects"

    def self.get_columns
        [
           
        ]
    end
   
end

