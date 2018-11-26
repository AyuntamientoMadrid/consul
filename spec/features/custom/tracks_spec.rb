require "rails_helper"

feature "Account verification" do
  scenario "In Spanish" do
    user = create(:user)
    login_as(user)

    visit verification_path(locale: :es)
    verify_residence(success_text: "Residencia verificada")
  end
end
