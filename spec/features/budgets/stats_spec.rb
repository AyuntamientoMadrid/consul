require 'rails_helper'

feature 'Stats' do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  context "Load" do

    before { budget.update(slug: "budget_slug", phase: "finished") }

    scenario "finds budget by slug" do
      visit budget_stats_path("budget_slug")

      expect(page).to have_content budget.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_stats_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_stats_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end

  end

  context "Show" do

    it "is not accessible to normal users if phase is not 'finished'" do
      budget.update(phase: 'reviewing_ballots')

      visit budget_stats_path(budget.id)
      expect(page).to have_content "You do not have permission to carry out the action "\
                                   "'read_stats' on budget."
    end

    it "is accessible to normal users if phase is 'finished'" do
      budget.update(phase: 'finished')

      visit budget_stats_path(budget.id)
      expect(page).to have_content "Stats"
    end

    it "is accessible to administrators when budget has phase 'reviewing_ballots'" do
      budget.update(phase: 'reviewing_ballots')

      login_as(create(:administrator).user)

      visit budget_stats_path(budget.id)
      expect(page).to have_content "Stats"
    end

    context "headings" do

      scenario "Displays headings ordered by name with city heading first" do
        budget.update(phase: 'finished')

        city_heading = create(:budget_heading, group: group, name: "City of New York")
        create(:budget_heading, group: group, name: "Brooklyn")
        create(:budget_heading, group: group, name: "Queens")
        create(:budget_heading, group: group, name: "Manhattan")

        allow_any_instance_of(Budget).to receive(:city_heading).and_return(city_heading)

        visit budget_stats_path(budget)
save_and_open_page
        within("#headings") do
          expect("City of New York").to appear_before("Brooklyn")
          expect("Brooklyn").to appear_before("Manhattan")
          expect("Manhattan").to appear_before("Queens")
        end
      end

    end

  end
end
