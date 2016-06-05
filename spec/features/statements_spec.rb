require 'rails_helper'

feature 'Statements' do

  scenario "Create" do
    create(:audit)

    visit "/"
    first(:link, "Open processes").click
    click_link "More information about Citizen Audit"
    first(:link, "Send information").click

    fill_in "statement_title", with: "Sketchy investment"
    fill_in "statement_body", with: "This investment..."
    page.attach_file('audit-attachment', Rails.root + 'spec/support/attachments/citizen_audit.png')
    click_button "Send information"

    expect(page).to have_content "Thank you. We have received your document."
  end

end