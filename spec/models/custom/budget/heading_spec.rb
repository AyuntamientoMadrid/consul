require "rails_helper"

describe Budget::Heading do
  describe ".sort_by_name" do
    it "returns the city heading first" do
      world = create(:budget_group)

      zimbabwe = create(:budget_heading, group: world, name: "Zimbabwe")
      city = create(:budget_heading, group: world, name: "Toda la ciudad")
      albania = create(:budget_heading, group: world, name: "Albania")

      expect(Budget::Heading.sort_by_name).to eq([city, albania, zimbabwe])
    end
  end
end
