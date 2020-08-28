require "rails_helper"

describe Mailer do
  describe "#comment" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")
      proposal = create(:proposal, author: user)
      comment = create(:comment, commentable: proposal)

      email = I18n.with_locale :en do
        described_class.comment(comment)
      end

      expect(email.subject).to include("comentado")
    end
  end

  describe "#confirmed_moderation" do
    let!(:comment) { create(:comment, body: "vulgar comment") }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "sends confirmed_moderation email" do
      Mailer.confirmed_moderation(comment).deliver_now

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(comment.author)
      expect(email).to have_subject I18n.t("mailers.moderable.confirmed_moderation_subject", moderable: I18n.t("mailers.moderable.resource.comment"))
      expect(email).to have_body_text(comment.body)
    end
  end

  describe "#declined_moderation" do
    let!(:comment) { create(:comment, body: "vulgar comment") }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "sends declined_moderation email" do
      Mailer.declined_moderation(comment).deliver_now

      email = open_last_email

      expect(email).to deliver_from("CONSUL <noreply@consul.dev>")
      expect(email).to deliver_to(comment.author)
      expect(email).to have_subject I18n.t("mailers.moderable.declined_moderation_subject", moderable: I18n.t("mailers.moderable.resource.comment"))
      expect(email).to have_body_text(comment.body)
    end
  end
end
