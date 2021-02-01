require "csv"

class ImportUser
  include ActiveModel::Model

  ATTRIBUTES = %w[username email document_number].freeze

  ALLOWED_FILE_EXTENSIONS = %w[.csv].freeze

  attr_accessor :file

  validates :file, presence: true
  validate :file_extension, if: -> { @file.present? }
  validate :valid_headers?, if: -> { @file.present? && valid_extension? }

  def initialize(attrs = {})
    if attrs.present?
      attrs.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
  end

  def save
    return false if invalid?

    CSV.open(file.path, headers: true).each do |row|
      next if empty_row?(row)
      build_user row
    end
    true
  end

  def save!
    validate! && save
  end

  private

    def build_user(row)
      user = User.new 
      user.attributes = row.to_hash.slice(*ATTRIBUTES)
      user
    end

    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    def file_extension
      return if valid_extension?
      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include?(File.extname(file.original_filename))
    end

    def valid_headers?
      headers = CSV.open(file.path, &:readline)

      # return if headers.all? { |header| ATTRIBUTES.include?(header) } &&
      #           ATTRIBUTES.all? { |attr| headers.include?(attr) }

      # errors.add :file, :headers, required_headers: ATTRIBUTES.join(", ")
    end
end
