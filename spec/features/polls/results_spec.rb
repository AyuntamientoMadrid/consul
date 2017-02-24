require 'rails_helper'

feature 'Results' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Display votes per answer and blank votes" do
    poll = create(:poll, name: "Gran Vía")
    question = create(:poll_question, poll: poll, valid_answers: "Yes, No" )
    ba = create(:poll_booth_assignment, poll: poll)

    create(:poll_partial_result, question: question, answer: "Yes", amount: 10)
    create(:poll_partial_result, question: question, answer: "No",  amount: 20)
    create(:poll_final_recount, booth_assignment: ba, count: 31)

    visit primera_votacion_results_path

    expect(page).to have_content "Gran Vía"

    within("table thead") do
      expect(all("tr th")[0].text).to eq("Yes")
      expect(all("tr th")[1].text).to eq("No")
      expect(all("tr th")[2].text).to eq("EN BLANCO")
    end

    within("table tbody") do
      expect(all("tr td")[0].text).to eq("10")
      expect(all("tr td")[1].text).to eq("20")
      expect(all("tr td")[2].text).to eq("1")
    end
  end

end