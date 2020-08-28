require "rails_helper"

feature "Moderated texts", type: :feature do
  let(:admin) { create(:administrator) }
  let(:comment) { create(:comment,
    body: "vulgar comment",
    commentable: create(:debate),
    user: admin.user)
  }

  background do
    login_as(admin.user)
  end

  context "Index" do
    it "shows a message when no words are moderated" do
      visit admin_moderated_texts_path
      expect(page).to have_content('There are no moderated words')
    end
  end

  context "New" do
    it "adds a new moderated word" do
      visit admin_moderated_texts_path
      click_link 'Create new text'

      expect(page).to have_content('New text')

      fill_in 'moderated_text_text', with: 'Bad word'
      click_button 'Create text'

      expect(page).to have_content('Bad word')
      expect(page).to have_content('Text created successfully')
    end

    it "adds a new moderated word with error" do
      visit admin_moderated_texts_path
      click_link 'Create new text'

      expect(page).to have_content('New text')

      click_button 'Create text'

      expect(page).to have_content('1 error prevented this text from being saved')
    end
  end

  context "Edit" do
    let!(:word) { create(:moderated_text, text: "vulgar") }
    let!(:offense) { create(:moderated_content,
      moderable: comment,
      moderated_text: word)
    }

    it "updates an existing word" do
      another_word = create(:moderated_text, text: "nasty")

      visit admin_moderated_texts_path
      expect(page).to have_content("nasty")

      within "#moderated_text_#{another_word.id}" do
        click_link "Edit"
      end

      fill_in "moderated_text_text", with: "disgusting"
      click_button "Modify word"

      expect(page).to have_content("disgusting")
      expect(page).not_to have_content("nasty")
      expect(page).to have_content("Word modified successfully")
    end

    it "does not allow modifying an existing word if it has associated offenses" do
      visit admin_moderated_texts_path

      within "#moderated_text_#{word.id}" do
        expect(page).to have_content("vulgar")
        expect(page).to have_content("1")
        expect(page).not_to have_link('Edit')
      end
    end
  end

  context "Delete" do
    let!(:word) { create(:moderated_text, text: "vulgar") }

    it "removes a moderated word", :js do
      visit admin_moderated_texts_path
      expect(page).to have_content('vulgar')

      accept_confirm { click_link 'Delete' }

      expect(page).to have_content('Word successfully deleted.')
      expect(page).not_to have_content('vulgar')
    end

    it "removes a moderated word with its associated offenses", :js do
      create(:moderated_content, moderable: comment, moderated_text: word)

      visit admin_moderated_texts_path

      within "#moderated_text_#{word.id}" do
        expect(page).to have_content("vulgar")
        expect(page).to have_content("1")
        accept_confirm { click_link 'Delete' }
      end

      expect(page).not_to have_content("vulgar")
      expect(page).not_to have_content("1")

      visit admin_auto_moderated_content_index_path

      expect(page).not_to have_content("vulgar")
      expect(page).not_to have_content("#{comment.body}")
      expect(page).to have_content("No comments have been automatically moderated")
    end
  end
end
