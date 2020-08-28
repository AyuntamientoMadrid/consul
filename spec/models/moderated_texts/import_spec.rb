require "rails_helper"

describe ModeratedTexts::Import do
  let(:import) { build(:moderated_text_import) }

  describe "Validations" do
    it "is valid" do
      expect(import).to be_valid
    end

    it "is not valid without a file" do
      import.file = nil
      expect(import).not_to be_valid
    end

    it "is not valid is the file is not CSV" do
      invalid_file = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.gif")
      import.file = invalid_file

      expect(import).not_to be_valid
    end

    it "is not valid if the headers are missing" do
      file_without_headers = Rack::Test::UploadedFile.new("spec/fixtures/files/moderated_texts/import/without_headers.csv")
      import.file = file_without_headers

      expect(import).not_to be_valid
    end

    it "is not valid if the headers are incorrect" do
      file_with_invalid_headers = Rack::Test::UploadedFile.new("spec/fixtures/files/moderated_texts/import/invalid.csv")
      import.file = file_with_invalid_headers

      expect(import).not_to be_valid
    end
  end
end
