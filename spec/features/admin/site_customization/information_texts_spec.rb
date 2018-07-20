require 'rails_helper'

feature "Admin custom information texts" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Information texts updating page is correctly loaded" do
    visit admin_site_customization_information_texts_path

    expect(page).to have_content "Custom information texts"
    expect(page).to have_content "Debates section description"

    within "#information-texts-tabs" do
      click_link "Proposals"
    end
    expect(page).to have_content "Recommendation 1 when create a topic on a proposal community"

    within "#information-texts-tabs" do
      click_link "Polls"
    end
    expect(page).to have_content "Polls description"

    within "#information-texts-tabs" do
      click_link "Participatory budgets"
    end
    expect(page).to have_content ""

    within "#information-texts-tabs" do
      click_link "More information"
    end
    expect(page).to have_content "Message when deleting an account"

    within "#information-texts-tabs" do
      click_link "Emails"
    end
    expect(page).to have_content "No reply message"

    within "#information-texts-tabs" do
      click_link "Management"
    end
    expect(page).to have_content "Printed proposal information"

  end

  scenario "Texts can be changed and they are correctly shown" do
    content = I18nContent.where(key: 'debates.index.section_footer.description').first
    old_text = content.value_en

    visit admin_site_customization_information_texts_path

    within "#tab-debates" do
      fill_in "contents_content_#{content.id}values_value_en", with: 'Custom debates text'
      click_button "Save"
    end

    visit debates_path

    expect(page).to have_content 'Custom debates text'
    expect(page).not_to have_content old_text
  end

  scenario "Texts falls back to predefined language if not exist", :js do
    content = I18nContent.where(key: 'debates.index.section_footer.description').first

    visit debates_path
    expect(page).to have_content content.value_en

    select('Español', from: 'locale-switcher')
    expect(page).to have_content content.value_es

    select('Français', from: 'locale-switcher')
    expect(page).to have_content content.value_es

  end

  scenario "Languages can be removed", :js do
    visit admin_site_customization_information_texts_path

    within("#tab-debates") do
      click_link 'Español'
      expect(page).to have_css('a.is-active', text: 'Español')

      click_link "Remove language"

      expect(page).not_to have_link('Español')

      click_button "Save"
    end

    content = I18nContent.where(key: 'debates.index.section_footer.description').first
    expect(content.value_es).to be nil
  end

  scenario "Languages can be added", :js do
    content = I18nContent.where(key: 'debates.index.section_footer.description').first

    visit admin_site_customization_information_texts_path

    within("#tab-debates") do
      select('Français', from: 'translation_locale')
      click_link 'Français'
      expect(page).to have_css('a.is-active', text: 'Français')

      fill_in "contents_content_#{content.id}values_value_fr", with: 'New title in french'

      click_button "Save"
    end

    expect(content.value_fr).to eq 'New title in french'
  end

end
