class Poll
  class Voter < ActiveRecord::Base
    belongs_to :booth_assignment
    delegate :poll, to: :booth_assignment

    validates :booth_assignment, presence: true
    validate :in_census
    validate :has_not_voted

    def in_census
      errors.add(:document_number, :not_in_census) unless census_api_response.valid?
    end

    def has_not_voted
      errors.add(:document_number, :has_voted, name: name) if has_voted?
    end

    def census_api_response
      @census ||= CensusApi.new.call(document_type, document_number)
    end

    def has_voted?
      poll.document_has_voted?(document_number, document_type)
    end

    def name
      @census.name
    end

  end
end