class Parbudget::Project < ApplicationRecord
    belongs_to :parbudget_responsible, class_name: "Parbudget::Responsible"
    belongs_to :parbudget_ambit, class_name: "Parbudget::Ambit"
    belongs_to :parbudget_local_forum, class_name: "Parbudget::Ambit"
    belongs_to :parbudget_topic, class_name: "Parbudget::Topic"
    has_many :parbudget_centers, class_name: "Parbudget::Center"
    has_many :parbudget_trackings, class_name: "Parbudget::Tracking"
    has_many :parbudget_links, class_name: "Parbudget::Link"
    has_many :parbudget_medias, class_name: "Parbudget::Media"
    has_many :parbudget_economic_budgets, class_name: "Parbudget::EconomicBudget"


    self.table_name = "parbudget_projects"

    def self.get_columns
        [
            :code,
            :year,
            :denomination,
            :responsible,
            :author,
            :votes
        ]
    end

    def self.get_exporter
        [
            :code,
            :year,
            :denomination,
            :responsible,
            :author,
            :email,
            :phone,
            :association,
            :url,
            :descriptive_memory,
            :entity_association,
            :plate_proceeds,
            :license_plate,
            :plate_installed,
            :assumes_dgpc,
            :code_old,
            :votes,
            :cost,
            :ambit,
            :topic
        ]
    end

    def responsible
        self.try(:parbudget_responsible).try(:full_name)
    end

    def ambit
        self.try(:parbudget_ambit).try(:name)
    end

    def topic
        self.try(:parbudget_topic).try(:name)
    end
end

