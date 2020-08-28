require "rails_helper"

feature "Moderated texts import", type: :feature do
  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "New" do
    it "renders the upload file form" do
      visit admin_moderated_texts_path
      click_link "Import CSV"

      expect(page).to have_content("Import from a CSV file")
      expect(page).to have_field("moderated_texts_import_file", type: "file")
    end

    it "renders an error if no file was selected" do
      visit new_admin_moderated_texts_import_path
      click_button "Save"
      expect(page).to have_content("can't be blank")
    end

    it "renders an error if an invalid file type was selected" do
      visit new_admin_moderated_texts_import_path

      path = "spec/fixtures/files/clippy.gif"
      attach_file("moderated_texts_import_file", Rails.root.join(path))
      click_button "Save"

      expect(page).to have_content("The file you're trying to upload is invalid. It must be in .csv format.")
    end

    it "uploads a file successfully" do
      visit new_admin_moderated_texts_import_path

      path = "spec/fixtures/files/moderated_texts/import/valid.csv"
      attach_file("moderated_texts_import_file", Rails.root.join(path))
      click_button "Save"

      expect(page).to have_content("The uploaded file was successfully processed")
      expect(page).to have_content("culo")
      expect(page).to have_content("cabron")
      expect(page).to have_content("mierda")
      expect(page).to have_content("imbecil")
    end

    it "uploads a file with similar texts successfully" do
      visit new_admin_moderated_texts_import_path

      path = "spec/fixtures/files/moderated_texts/import/valid.csv"
      attach_file("moderated_texts_import_file", Rails.root.join(path))
      click_button "Save"

      expect(page).to have_content("The uploaded file was successfully processed")
      expect(page).to have_content("culo")
      expect(page).to have_content("cabron")
      expect(page).to have_content("mierda")
      expect(page).to have_content("imbecil")

      visit new_admin_moderated_texts_import_path
      path = "spec/fixtures/files/moderated_texts/import/valid_updated.csv"
      attach_file("moderated_texts_import_file", Rails.root.join(path))
      click_button "Save"

      expect(page).to have_content("The uploaded file was successfully processed")
      expect(page).to have_content("culo")
      expect(page).to have_content("cabron")
      expect(page).to have_content("mierda")
      expect(page).to have_content("imbecil")
      expect(page).to have_content("cabrón")
    end
  end
end
