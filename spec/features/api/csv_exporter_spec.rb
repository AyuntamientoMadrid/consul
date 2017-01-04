require 'rails_helper'
require 'csv'

feature 'CSV Exporter' do

  background do
    @csv_exporter = API::CSVExporter.new
  end

  context "Proposals" do

    scenario "Attributes" do
      proposal = create(:proposal)
      @csv_exporter.export

      visit csv_path_for("proposals")
      csv = CSV.parse(page.html)

      columns = [
        "id",
        "title",
        "description",
        "external_url",
        "cached_votes_up",
        "comments_count",
        "hot_score",
        "confidence_score",
        "created_at",
        "summary",
        "video_url",
        "geozone_id",
        "retired_at",
        "retired_reason",
        "retired_explanation",
        "proceeding",
        "sub_proceeding"]

      proposal_line = CSV.parse(@csv_exporter.public_attributes(proposal).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(proposal_line)
    end

    scenario "Do not include hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal.title)
      expect(csv).to_not include(hidden_proposal.title)
    end

    scenario "Only include proposals of the Human Rights proceeding" do
      proposal = create(:proposal)
      human_rights_proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Right to have a job")
      other_proceeding_proposal = create(:proposal)
      other_proceeding_proposal.update_attribute(:proceeding, "Another proceeding")

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(proposal.title)
      expect(csv).to include(human_rights_proposal.title)
      expect(csv).to_not include(other_proceeding_proposal.title)
    end

    scenario "Only displays proposals of authors with public activity" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_proposal = create(:proposal, author: visible_author)
      hidden_proposal  = create(:proposal, author: hidden_author)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal.title)
      expect(csv).to_not include(hidden_proposal.title)
    end

  end

  context "Debates" do

    scenario "Attributes" do
      debate = create(:debate)
      @csv_exporter.export

      visit csv_path_for("debates")
      csv = CSV.parse(page.html)

      columns = [
        "id",
        "title",
        "description",
        "created_at",
        "cached_votes_total",
        "cached_votes_up",
        "cached_votes_down",
        "comments_count",
        "hot_score",
        "confidence_score"]

      debate_line = CSV.parse(@csv_exporter.public_attributes(debate).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(debate_line)
    end

    scenario "Do not include hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_debate.title)
      expect(csv).to_not include(hidden_debate.title)
    end

    scenario "Only display debates of authors with public activity" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_debate = create(:debate, author: visible_author)
      hidden_debate  = create(:debate, author: hidden_author)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_debate.title)
      expect(csv).to_not include(hidden_debate.title)
    end

  end

  context "Comments" do

    scenario "Attributes" do
      comment = create(:comment)
      @csv_exporter.export

      visit csv_path_for("comments")
      csv = CSV.parse(page.html)

      columns = [
        "id",
        "commentable_id",
        "commentable_type",
        "body",
        "created_at",
        "cached_votes_total",
        "cached_votes_up",
        "cached_votes_down",
        "ancestry",
        "confidence_score"]

      comment_line = CSV.parse(@csv_exporter.public_attributes(comment).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(comment_line)
    end

    scenario "Only include comments from proposals and debates" do
      proposal_comment          = create(:comment, commentable: create(:proposal))
      debate_comment            = create(:comment, commentable: create(:debate))
      spending_proposal_comment = create(:comment, commentable: create(:spending_proposal))

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(proposal_comment.body)
      expect(csv).to include(debate_comment.body)
      expect(csv).to_not include(spending_proposal_comment.body)
    end

    scenario "Only displays comments of authors with public activity" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_comment = create(:comment, user: visible_author)
      hidden_comment  = create(:comment, user: hidden_author)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_comment.body)
      expect(csv).to_not include(hidden_comment.body)
    end

    scenario "Do not include hidden comments" do
      visible_comment = create(:comment)
      hidden_comment  = create(:comment, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_comment.body)
      expect(csv).to_not include(hidden_comment.body)
    end

    scenario "Do not include comments from hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_comment = create(:comment, commentable: visible_proposal)
      hidden_proposal_comment  = create(:comment, commentable: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal_comment.body)
      expect(csv).to_not include(hidden_proposal_comment.body)
    end

    scenario "Do not include comments from hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      visible_debate_comment = create(:comment, commentable: visible_debate)
      hidden_debate_comment  = create(:comment, commentable: hidden_debate)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_debate_comment.body)
      expect(csv).to_not include(hidden_debate_comment.body)
    end

  end

  context "Geozones" do

    scenario "Attributes" do
      geozone = create(:geozone)
      @csv_exporter.export

      visit csv_path_for("geozones")
      csv = CSV.parse(page.html)

      columns = ["id", "name"]

      geozone_line = CSV.parse(@csv_exporter.public_attributes(geozone).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(geozone_line)
    end

  end

  context "Proposal notifications" do

    scenario "Attributes" do
      proposal_notification = create(:proposal_notification)
      @csv_exporter.export

      visit csv_path_for("proposal_notifications")
      csv = CSV.parse(page.html)

      columns = [
        "title",
        "body",
        "proposal_id",
        "created_at"]

      proposal_notification_line = CSV.parse(@csv_exporter.public_attributes(proposal_notification).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(proposal_notification_line)
    end

    scenario "Do not include proposal notifications for hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_notification = create(:proposal_notification, proposal: visible_proposal)
      hidden_proposal_notification  = create(:proposal_notification, proposal: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("proposal_notifications")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal_notification.title)
      expect(csv).to_not include(hidden_proposal_notification.title)
    end

  end

  context "Tags" do

    scenario "Attributes" do
      create(:proposal, tag_list: "Health")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = CSV.parse(page.html)

      columns = [
        "name",
        "taggings_count",
        "kind"]

      tag_line = CSV.parse(@csv_exporter.public_attributes(Tag.first).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(tag_line)
    end

    scenario "Only display tags with kind nil or category" do
      tag           = create(:tag, name: "Parks")
      category_tag  = create(:tag, name: "Health",    kind: "category")
      admin_tag     = create(:tag, name: "Admin tag", kind: "admin")

      proposal = create(:proposal, tag_list: "Parks")
      proposal = create(:proposal, tag_list: "Health")
      proposal = create(:proposal, tag_list: "Admin tag")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include("Parks")
      expect(csv).to include("Health")
      expect(csv).to_not include("Admin tag")
    end

    scenario "Do not display tags for hidden proposals" do
      proposal = create(:proposal, tag_list: "Health")
      hidden_proposal = create(:proposal, tag_list: "SPAM", hidden_at: Time.now)

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include("Health")
      expect(csv).to_not include("SPAM")
    end

    scenario "Do not display tags for hidden debates" do
      debate = create(:debate, tag_list: "Health")
      hidden_debate = create(:debate, tag_list: "SPAM", hidden_at: Time.now)

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include("Health")
      expect(csv).to_not include("SPAM")
    end

  end

  context "Taggings" do

    scenario "Attributes" do
      tagging = create(:tagging)
      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = CSV.parse(page.html)

      columns = [
        "tag_id",
        "taggable_id",
        "taggable_type"]

      tagging_line = CSV.parse(@csv_exporter.public_attributes(tagging).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(tagging_line)
    end

    scenario "Only include taggings for proposals and debates" do
      proposal          = create(:proposal)
      debate            = create(:debate)
      spending_proposal = create(:spending_proposal)

      proposal_tagging          = create(:tagging, taggable: proposal)
      debate_tagging            = create(:tagging, taggable: debate)
      spending_proposal_tagging = create(:tagging, taggable: spending_proposal)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(proposal_tagging.taggable_type)
      expect(csv).to include(debate_tagging.taggable_type)
      expect(csv).to_not include(spending_proposal_tagging.taggable_type)
    end

    scenario "Do not include taggings for hidden taggables" do
      visible_proposal = create(:proposal)
      hidden_debate = create(:debate, hidden_at: Time.now)

      visible_proposal_tagging = create(:tagging, taggable: visible_proposal)
      hidden_debate_tagging    = create(:tagging, taggable: hidden_debate)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal_tagging.taggable_type)
      expect(csv).to_not include(hidden_debate_tagging.taggable_type)
    end

    scenario "Do not display taggings for hidden tags" do
      category_tag  = create(:tag, name: "Health",    kind: "category")
      admin_tag     = create(:tag, name: "Admin tag", kind: "admin")

      visible_tag_tagging = create(:tagging, tag: category_tag, taggable: create(:proposal))
      hidden_tag_tagging  = create(:tagging, tag: admin_tag, taggable: create(:debate))

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_tag_tagging.taggable_type)
      expect(csv).to_not include(hidden_tag_tagging.taggable_type)
    end

  end

  context "Votes" do

    scenario "Attributes", :focus do
      vote = create(:vote)
      @csv_exporter.export

      visit csv_path_for("votes")
      csv = CSV.parse(page.html)

      columns = [
        "votable_id",
        "votable_type",
        "vote_flag",
        "created_at"]

      vote_line = CSV.parse(@csv_exporter.public_attributes(vote).join(',')).first

      expect(csv.first).to eq(columns)
      expect(csv).to include(vote_line)
    end

    scenario "Only include votes from proposals, debates and comments", :focus do
      proposal = create(:proposal)
      debate   = create(:debate)
      comment  = create(:comment)
      spending_proposal = create(:spending_proposal)

      proposal_vote = create(:vote, votable: proposal)
      debate_vote   = create(:vote, votable: debate)
      comment_vote  = create(:vote, votable: comment)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(proposal_vote.votable_type)
      expect(csv).to include(debate_vote.votable_type)
      expect(csv).to include(comment_vote.votable_type)
      expect(csv).to_not include(spending_proposal_vote.votable_type)
    end

    scenario "Do not include votes of a hidden votable" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_vote = create(:vote, votable: visible_proposal)
      hidden_proposal_vote  = create(:vote, votable: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = CSV.parse(page.html).flatten

      expect(csv).to include(visible_proposal_vote.votable_id.to_s)
      expect(csv).to_not include(hidden_proposal_vote.votable_id.to_s)
    end

  end

end