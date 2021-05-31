require "rails_helper"

describe "Legislation" do
  context "process debate page" do
    before do
      @process = create(:legislation_process, debate_start_date: Date.current - 3.days, debate_end_date: Date.current + 2.days)
      create(:legislation_question, process: @process, title: "Question 1")
      create(:legislation_question, process: @process, title: "Question 2")
      create(:legislation_question, process: @process, title: "Question 3")
    end

    scenario "shows question list" do
      visit legislation_process_path(@process)

      expect(page).to have_content("Participate in the debate")

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Question 2")
      expect(page).to have_content("Question 3")

      click_link "Question 1"

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 2")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 3")
      expect(page).not_to have_content("Next question")
    end

    scenario "shows question page" do
      visit legislation_process_question_path(@process, @process.questions.first)

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Open answers (0)")
    end

    scenario "shows next question link in question page" do
      visit legislation_process_question_path(@process, @process.questions.first)

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 2")
      expect(page).to have_content("Next question")

      click_link "Next question"

      expect(page).to have_content("Question 3")
      expect(page).not_to have_content("Next question")
    end

    scenario "answer question" do
      question = @process.questions.first
      create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_question_option, question: question, value: "No")
      option = create(:legislation_question_option, question: question, value: "I don't know")
      user = create(:user, :level_two)

      login_as(user)

      visit legislation_process_question_path(@process, question)

      expect(page).to have_selector(:radio_button, "Yes")
      expect(page).to have_selector(:radio_button, "No")
      expect(page).to have_selector(:radio_button, "I don't know")
      expect(page).to have_selector(:link_or_button, "Submit answer")

      choose("I don't know")
      click_button "Submit answer"

      within(:css, "label.is-active") do
        expect(page).to have_content("I don't know")
        expect(page).not_to have_content("Yes")
        expect(page).not_to have_content("No")
      end
      expect(page).not_to have_selector(:link_or_button, "Submit answer")

      expect(question.reload.answers_count).to eq(1)
      expect(option.reload.answers_count).to eq(1)
    end

    scenario "cannot answer question when phase not open" do
      @process.update_attribute(:debate_end_date, Date.current - 1.day)
      question = @process.questions.first
      create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_question_option, question: question, value: "No")
      create(:legislation_question_option, question: question, value: "I don't know")
      user = create(:user, :level_two)

      login_as(user)

      visit legislation_process_question_path(@process, question)

      expect(page).to have_selector(:radio_button, "Yes", disabled: true)
      expect(page).to have_selector(:radio_button, "No", disabled: true)
      expect(page).to have_selector(:radio_button, "I don't know", disabled: true)

      expect(page).not_to have_selector(:link_or_button, "Submit answer")
    end

    context "question clarity", :js do
      scenario "shows votes section on sidebar" do
        visit legislation_process_question_path(@process, @process.questions.first)

        within "aside" do
          expect(page).to have_selector("h3", text: "HELP US TO IMPROVE!")
          expect(page).to have_content("Does the question of this debate seem clear to you?")
          expect(page).to have_button("Clear", disabled: true)
          expect(page).to have_button("Confusing", disabled: true)
        end
      end

      scenario "when the user is not logged in is not allowed to participate" do
        visit legislation_process_question_path(@process, @process.questions.first)

        within "aside" do
          find("div.votes").hover
          expect(page).to have_content "You must Sign in or Sign up to continue."
          expect(page).to have_selector(".participation-allowed", visible: false)
          expect(page).to have_selector(".participation-not-allowed", visible: true)
        end
      end

      scenario "when the user is not level two is not allowed to participate" do
        user = create(:user)
        login_as(user)
        visit legislation_process_question_path(@process, @process.questions.first)

        within "aside" do
          find("div.votes").hover
          expect(page).to have_content("You must be a verified user to participate, verify your account.")
          expect(page).to have_selector(".participation-allowed", visible: false)
          expect(page).to have_selector(".participation-not-allowed", visible: true)
        end
      end

      context "when the user has level two verification" do
        before do
          user = create(:user, :level_two)
          login_as(user)
        end

        scenario "is able to vote and change the vote direction" do
          visit legislation_process_question_path(@process, @process.questions.first)

          within "aside" do
            click_button "Clear"

            expect(page).to have_css("button.voted.like")

            click_button "Confusing"

            expect(page).not_to have_css("button.voted.like")
            expect(page).to have_css("button.voted.unlike")
          end
        end
      end
    end
  end
end
