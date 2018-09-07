require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user, verified_at: Time.current)
  end

  feature 'Investments' do

    let(:budget)  { create(:budget, phase: "selecting") }
    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    background { login_as(@manuela) }

    feature 'Index' do

      scenario "Index shows user votes on proposals" do
        investment1 = create(:budget_investment, heading: heading)
        investment2 = create(:budget_investment, heading: heading)
        investment3 = create(:budget_investment, heading: heading)
        create(:vote, voter: @manuela, votable: investment1, vote_flag: true)

        visit budget_investments_path(budget, heading_id: heading.id)

        within("#budget-investments") do
          within("#budget_investment_#{investment1.id}_votes") do
            expect(page).to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment2.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment3.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end
        end
      end

      scenario 'Create from spending proposal index', :js do
        investment = create(:budget_investment, heading: heading, budget: budget)

        visit budget_investments_path(budget, heading_id: heading.id)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end
      end
    end

    feature 'Single spending proposal' do
      background do
        @investment = create(:budget_investment, budget: budget, heading: heading)
      end

      scenario 'Show no votes' do
        visit budget_investment_path(budget, @investment)
        expect(page).to have_content "No supports"
      end

      scenario 'Trying to vote multiple times', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click
          expect(page).to have_content "1 support"

          expect(page).not_to have_selector ".in-favor a"
        end
      end

      scenario 'Create from proposal show', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end
      end
    end

    scenario 'Disable voting on spending proposals', :js do
      login_as(@manuela)
      budget.update(phase: "reviewing")
      investment = create(:budget_investment, budget: budget, heading: heading)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end
    end

    context "Supporting in multiple headings of a single group" do
      let(:heading1) { create(:budget_heading, group: group) }
      let(:heading2) { create(:budget_heading, group: group) }
      let(:heading3) { create(:budget_heading, group: group) }
      let(:heading4) { create(:budget_heading, group: group) }

      let!(:heading1_investment1) { create(:budget_investment, heading: heading1) }
      let!(:heading1_investment2) { create(:budget_investment, heading: heading1) }
      let!(:heading2_investment) { create(:budget_investment, heading: heading2) }
      let!(:heading3_investment) { create(:budget_investment, heading: heading3) }
      let!(:heading4_investment) { create(:budget_investment, heading: heading4) }

      context "With only 1 supportable headings" do
        background do
          group.update(max_supportable_headings: 1)
        end

        scenario "From Index", :js do
          visit budget_investments_path(budget, heading_id: heading1.id)

          within("#budget_investment_#{heading1_investment1.id}") do
            accept_confirm { find('.in-favor a').click }
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          within("#budget_investment_#{heading1_investment2.id}") do
            find('.in-favor a').click
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          visit budget_investments_path(budget, heading_id: heading2.id)

          within("#budget_investment_#{heading2_investment.id}") do
            find('.in-favor a').click
            expect(page).to have_content "You have reached the maximum supportable investments "\
                                         "in this group (1)"
          end

          visit budget_investments_path(budget, heading_id: heading3.id)

          within("#budget_investment_#{heading3_investment.id}") do
            find('.in-favor a').click
            expect(page).to have_content "You have reached the maximum supportable investments "\
                                         "in this group (1)"
          end
        end

        scenario "From show", :js do
          visit budget_investment_path(budget, heading1_investment1)

          accept_confirm { find('.in-favor a').click }
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading1_investment2)

          find('.in-favor a').click
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading2_investment)

          find('.in-favor a').click
          expect(page).to have_content "You have reached the maximum supportable investments "\
                                       "in this group (1)"

          visit budget_investment_path(budget, heading3_investment)

          find('.in-favor a').click
          expect(page).to have_content "You have reached the maximum supportable investments "\
                                       "in this group (1)"
        end
      end

      context "With more than 1 supportable headings" do
        background do
          group.update(max_supportable_headings: 3)
        end

        scenario "From Index", :js do
          visit budget_investments_path(budget, heading_id: heading1.id)

          within("#budget_investment_#{heading1_investment1.id}") do
            accept_confirm { find('.in-favor a').click }
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          within("#budget_investment_#{heading1_investment2.id}") do
            find('.in-favor a').click
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          visit budget_investments_path(budget, heading_id: heading2.id)

          within("#budget_investment_#{heading2_investment.id}") do
            find('.in-favor a').click
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          visit budget_investments_path(budget, heading_id: heading3.id)

          within("#budget_investment_#{heading3_investment.id}") do
            find('.in-favor a').click
            expect(page).to have_content "1 support"
            expect(page).to have_content "You have already supported this investment project."
          end

          visit budget_investments_path(budget, heading_id: heading4.id)

          within("#budget_investment_#{heading4_investment.id}") do
            find('.in-favor a').click
            expect(page).to have_content "You have reached the maximum supportable investments "\
                                         "in this group (3)"
          end
        end

        scenario "From show", :js do
          visit budget_investment_path(budget, heading1_investment1)

          accept_confirm { find('.in-favor a').click }
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading1_investment2)

          find('.in-favor a').click
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading2_investment)

          find('.in-favor a').click
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading3_investment)

          find('.in-favor a').click
          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project."

          visit budget_investment_path(budget, heading4_investment)

          find('.in-favor a').click
          expect(page).to have_content "You have reached the maximum supportable investments "\
                                       "in this group (3)"
        end
      end
    end

    context "User supports in a group heading" do
      scenario "should record the heading support the first time" do
        login_as(@manuela)
        budget.update(phase: "selecting")
        investment = create(:budget_investment, budget: budget, heading: heading)

        visit budget_investment_path(budget, investment)
        find('.in-favor a').click

        expect(Budget::Heading::Support.all.count).to be(1)
      end

      scenario "should not record the heading support again if it was supported before" do
        login_as(@manuela)
        budget.update(phase: "selecting")
        investment1 = create(:budget_investment, budget: budget, heading: heading)
        investment2 = create(:budget_investment, budget: budget, heading: heading)
        create(:vote, votable: investment2, voter: @manuela)

        visit budget_investment_path(budget, investment1)
        find('.in-favor a').click

        expect(Budget::Heading::Support.all.count).to be(1)
      end
    end

    context "Reclassification" do
      context "Investment is reclassified from heading A to heading B" do
        let(:heading_A) { create(:budget_heading, group: group) }
        let(:heading_B) { create(:budget_heading, group: group) }
        let(:investment1) { create(:budget_investment, budget: budget, heading: heading_A) }
        let(:investment2) { create(:budget_investment, budget: budget, heading: heading_A) }
        let(:investment3) { create(:budget_investment, budget: budget, heading: heading_B) }

        background do
          group.update(max_supportable_headings: 1)

          login_as(@manuela)

          create(:vote, votable: investment1, voter: @manuela)
          create(:budget_heading_support, user_id: @manuela.id, budget_heading_id: heading_A.id)
          investment1.update(heading_id: heading_B.id)
        end

        scenario "user who supported investment in heading A can't support in heading B", :js do
          visit budget_investment_path(budget, investment3)

          find('.in-favor a').click

          expect(page).to have_content "You have reached the maximum supportable investments "\
                                       "in this group (1)"
        end

        scenario "user who supported in heading A can still support investments there", :js do
          visit budget_investment_path(budget, investment2)

          find('.in-favor a').click
          expect(page).to have_content "1 support"
        end
      end
    end
  end
end
