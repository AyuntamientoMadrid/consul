require "rails_helper"

feature "Secure sign in" do
  after { Setting["security.safe_sign_in_from"] = nil }

  let(:user) { create(:user) }

  let :set_safe_sign_in_from do
    Rake.application.rake_require "tasks/settings"
    Rake::Task.define_task(:environment)
    Rake::Task["settings:set_safe_sign_in_from"].reenable
    Rake.application.invoke_task "settings:set_safe_sign_in_from"
  end

  let :login_and_initialize_current_sign_in_at do
    login_as(user)
    visit root_url
  end

  scenario "User signed in before the previous newsletter" do
    login_and_initialize_current_sign_in_at
    user.update(current_sign_in_at: Time.new(2018, 10, 23, 12, 30, 00))
    set_safe_sign_in_from

    visit root_url

    expect_to_be_signed_in
  end

  scenario "User signed in after the previous newsletter and before it was 100% safe" do
    login_and_initialize_current_sign_in_at
    set_safe_sign_in_from

    visit root_url

    expect_to_not_be_signed_in
  end

  scenario "User signed in after it was 100% safe to do so" do
    set_safe_sign_in_from
    login_and_initialize_current_sign_in_at

    visit root_url

    expect_to_be_signed_in
  end

  scenario "No safe sign in from is defined" do
    Setting["security.safe_sign_in_from"] = nil
    login_and_initialize_current_sign_in_at

    visit root_url

    expect_to_be_signed_in
  end
end
