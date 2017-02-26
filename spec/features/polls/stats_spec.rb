require 'rails_helper'
require 'rake'


  background do
    admin = create(:administrator)
    login_as(admin.user)

    Consul::Application.load_tasks
    Rake::Task['stats:polls_2017'].invoke
  end

  scenario "Votes" do
    oa = create(:poll_officer_assignment)

    2.times { create(:poll_voter, origin: "web") }
    3.times { create(:poll_voter, origin: "booth",  officer_assignment: oa) }
    4.times { create(:poll_voter, origin: "letter") }

    visit primera_votacion_stats_path

    within("#total_votes") do
      expect(page).to have_content "9"
    end

    within("#total_web_votes") do
      expect(page).to have_content "2"
      expect(page).to have_content "22%"
    end

    within("#total_booth_votes") do
      expect(page).to have_content "3"
      expect(page).to have_content "33%"
    end

    within("#total_letter_votes") do
      expect(page).to have_content "4"
      expect(page).to have_content "44%"
    end

    within("#total_votes_table") do
      expect(page).to have_content "9"
    end
  end

  scenario "Participants" do
    user1 = create(:user, :level_two)
    user2 = create(:user, :level_two)
    user3 = create(:user, :level_two)
    user4 = create(:user, :level_two)
    user5 = create(:user, :level_two)
    user6 = create(:user, :level_two)

    oa = create(:poll_officer_assignment)

    create(:poll_voter, origin: "web", user: user1)

    create(:poll_voter, origin: "booth", user: user2,  officer_assignment: oa)
    create(:poll_voter, origin: "booth", user: user3,  officer_assignment: oa)

    create(:poll_voter, origin: "letter", user: user4)
    create(:poll_voter, origin: "letter", user: user5)
    create(:poll_voter, origin: "letter", user: user6)

    visit primera_votacion_stats_path

    within("#total_participants") do
      expect(page).to have_content "6"
    end

    within("#total_web_participants") do
      expect(page).to have_content "1"
      expect(page).to have_content "16%"
    end

    within("#total_booth_participants") do
      expect(page).to have_content "2"
      expect(page).to have_content "33%"
    end

    within("#total_letter_participants") do
      expect(page).to have_content "3"
      expect(page).to have_content "50%"
    end

    within("#total_participants_table") do
      expect(page).to have_content "6"
    end
  end

end