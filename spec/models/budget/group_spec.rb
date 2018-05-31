require 'rails_helper'

describe Budget::Group do
  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "Validations" do

    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

    describe "name" do
      before do
        create(:budget_group, budget: budget, name: 'object name')
      end

      it "can be repeatead in other budget's groups" do
        expect(build(:budget_group, budget: create(:budget), name: 'object name')).to be_valid
      end

      it "must be unique among all budget's groups" do
        expect(build(:budget_group, budget: budget, name: 'object name')).not_to be_valid
      end
    end

    describe "max_supportable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_supportable_headings = 0
        expect(group).not_to be_valid
      end
    end

    describe "max_votable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_votable_headings = 0
        expect(group).not_to be_valid
      end
    end
  end

  describe "#reached_max_supportable_headings?" do
    let(:user) { create(:user) }
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }
    let(:heading1) { create(:budget_heading, group: group) }
    let(:heading2) { create(:budget_heading, group: group) }
    let(:investment1) { create(:budget_investment, budget: budget, heading: heading1) }
    let(:investment2) { create(:budget_investment, budget: budget, heading: heading2) }

    before do
      group.update(max_supportable_headings: 2)
    end

    it "returns true if user has supported the max headings in this group" do
      create(:vote, votable: investment1, voter: user)
      create(:budget_heading_support, user: user, budget_heading: heading1)
      create(:vote, votable: investment2, voter: user)
      create(:budget_heading_support, user: user, budget_heading: heading2)

      expect(group.reached_max_supportable_headings?(user)).to be(true)
    end

    it "returns false if user hasn't supported the max headings in this group" do
      create(:vote, votable: investment1, voter: user)
      create(:budget_heading_support, user: user, budget_heading: heading1)

      expect(group.reached_max_supportable_headings?(user)).to be(false)
    end
  end
end
