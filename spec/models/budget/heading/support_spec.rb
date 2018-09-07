require 'rails_helper'

describe Budget::Heading::Support do

  describe "Validations" do
    let(:budget_heading_support) { build(:budget_heading_support) }

    it "is valid" do
      expect(budget_heading_support).to be_valid
    end

    it "is not valid without user_id" do
      budget_heading_support.user_id = nil
      expect(budget_heading_support).not_to be_valid
    end

    it "is not valid without budget_heading_id" do
      budget_heading_support.budget_heading_id = nil
      expect(budget_heading_support).not_to be_valid
    end
  end

end
