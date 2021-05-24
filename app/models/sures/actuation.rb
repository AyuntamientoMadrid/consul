class Sures::Actuation < ApplicationRecord

    has_many :actuations_multi_years, -> { order(:id) }, class_name: "ActuationsMultiYear", foreign_key: "sures_actuations_id",
                        dependent: :destroy, inverse_of: :sures_actuations
    accepts_nested_attributes_for :actuations_multi_years, reject_if: proc { |attributes| attributes.all? { |k, v| v.blank? } }, allow_destroy: true

    has_many :adress

    scope :study, -> { where(status: "study") }
    scope :tramit, -> { where(status: "tramit") }
    scope :process, -> { where(status: "process") }
    scope :fhinish, -> { where(status: "fhinish") }

    self.table_name = "sures_actuations"

    translates :proposal_title,         touch: true
    translates :proposal_objective,     touch: true
    translates :territorial_scope,      touch: true
    translates :location_performance,   touch: true
    translates :technical_visibility,   touch: true
    translates :actions_taken,          touch: true
    include Globalizable


    validates :proposal_title, presence: true
    validates :status, presence: true
    validate :valid_annos

    private

    def valid_annos
        if self.check_anno.to_s == "true"
            if !self.annos.match(/^\d{4}$/)
                self.errors.add(:annos, "Se han introducido más de 4 dígitos o formato incorrecto")
            end
        end
    end
end

