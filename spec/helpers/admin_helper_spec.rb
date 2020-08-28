require "rails_helper"

describe AdminHelper do

  describe "#admin_submit_action" do

    it "returns new when the the resource has not been persisted" do
      poll = build(:poll)
      expect(admin_submit_action(poll)).to eq("new")
    end

    it "returns edit when the the resource has been persisted" do
      poll = create(:poll)
      expect(admin_submit_action(poll)).to eq("edit")
    end

  end

  describe "#moderated_date" do
    it "returns declined_at with format datetime when moderated_content is declined" do
      moderated_content = create(:moderated_content, :declined)

      expect(moderated_date(moderated_content.comment)).to eq(I18n.l(moderated_content.declined_at, format: :datetime))
    end

    it "returns confirmed_at with format datetime when moderated_content is confirmed" do
      moderated_content = create(:moderated_content, :confirmed)

      expect(moderated_date(moderated_content.comment)).to eq(I18n.l(moderated_content.confirmed_at, format: :datetime))
    end
  end

end
