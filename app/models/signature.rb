class Signature < ActiveRecord::Base
  belongs_to :signature_sheet
  belongs_to :user

  validates :document_number, presence: true
  validates :signature_sheet, presence: true

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  delegate :signable, to: :signature_sheet

  before_validation :clean_document_number

  def verify
    return if exists?

    if user_exists?
      assign_vote_to_user
      mark_as_verified
    elsif in_census?
      create_user
      assign_vote_to_user
      mark_as_verified
    end
  end

  def exists?
    Signature.where(signature_sheet: signature_sheet)
             .where("document_number like ?", "#{document_number_without_letter}%").any?
  end

  def assign_vote_to_user
    set_user
    if signable.is_a? Budget::Investment
      signable.vote_by(voter: user, vote: 'yes') if user_can_sign?
    else
      signable.register_vote(user, "yes")
    end
    assign_signature_to_vote
  end

  def assign_signature_to_vote
    vote = Vote.where(votable: signable, voter: user).first
    vote.update(signature: self) if vote
  end

  def user_exists?
    possible_user_matches.count.positive?
  end

  def create_user
    user_params = {
      document_number: document_number,
      created_from_signature: true,
      verified_at: Time.current,
      erased_at: Time.current,
      password: random_password,
      terms_of_service: '1',
      email: nil,
      date_of_birth: @census_api_response.date_of_birth,
      gender: @census_api_response.gender,
      geozone: Geozone.where(census_code: @census_api_response.district_code).first
    }
    User.create!(user_params)
  end

  def clean_document_number
    return if document_number.blank?
    self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase
  end

  def random_password
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def in_census?
    document_types.detect do |document_type|
      response = CensusCaller.new.call(document_type, document_number)
      if response.valid?
        @census_api_response = response
        true
      else
        false
      end
    end

    @census_api_response.present?
  end

  def set_user
    user = possible_user_matches.first
    update(user: user)
  end

  def user_can_sign?
    possible_user_matches.all? do |user_match|
      [nil, :no_selecting_allowed].include?(signable.reason_for_not_being_selectable_by(user_match))
    end
  end

  def possible_user_matches
    document_number_alternatives.map do |document_number_alternative|
      User.where(document_number: document_number_alternative).first
    end.compact
  end

  def document_number_alternatives
    [document_number,
     document_number_without_letter,
     format_spanish_id]
  end

  def mark_as_verified
    update(verified: true)
  end

  def document_types
    %w(1 2 3 4)
  end

  private

    def document_number_without_letter
      document_number.gsub(/[A-Za-z]/, "")
    end

    def format_spanish_id
      format_spanish_id_digits(document_number_without_letter) +
        calculate_spanish_id_letter(document_number_without_letter)
    end

    def format_spanish_id_digits(spanish_id_digits)
      spanish_id_digits.length < 8 ? "%08d" % spanish_id_digits.to_i : spanish_id_digits
    end

    def calculate_spanish_id_letter(spanish_id_digits)
      'TRWAGMYFPDXBNJZSQVHLCKE'[spanish_id_digits.to_i % 23].chr
    end
end
