require "rails_helper"

describe ModeratedText do
  it "is valid" do
    bad_word = build(:moderated_text)
    expect(bad_word).to be_valid
  end

  it "is valid only with non-empty text" do
    another_bad_word = build(:moderated_text, text: '')
    expect(another_bad_word).not_to be_valid
  end

  it "is valid when the word is unique" do
    bad_word = create(:moderated_text)
    another_bad_word = build(:moderated_text)
    expect(another_bad_word).not_to be_valid
  end

  describe "#default_scope" do
    it "sorts moderated words by text ASC" do
      bad_word = create(:moderated_text, text: "fluff", created_at: 1.day.ago)
      another_bad_word = create(:moderated_text, text: "canard")

      words = described_class.all.pluck(:text)

      expect(words).to eq(%w[canard fluff])
    end
  end
end
