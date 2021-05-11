require "rails_helper"

describe "Communities" do

  before do
    Setting["feature.community"] = true
  end

  after do
    Setting["feature.community"] = nil
  end

  context "Show" do

    scenario "Should display default content" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      login_as(user)

      visit community_path(community)

      expect(page).to have_content "Proposal community"
      expect(page).to have_content proposal.title
      expect(page).to have_content "Participate in the community of this proposal"
      expect(page).to have_link("Create topic", href: new_community_topic_path(community))
    end

    scenario "Should display without_topics_text and participants when there are not topics" do
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(page).to have_content "Create the first community topic"
      expect(page).to have_content "Participants (1)"
    end

    scenario "Should display order selector and topic content when there are topics" do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)
      create(:comment, commentable: topic)

      visit community_path(community)

      expect(page).to have_selector ".wide-order-selector"
      within "#topic_#{topic.id}" do
        expect(page).to have_content topic.title
        expect(page).to have_content "#{topic.comments_count} comment"
        expect(page).to have_content I18n.l(topic.created_at.to_date)
        expect(page).to have_content topic.author.name
      end
    end

    scenario "Topic order" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)
      topic2_comment = create(:comment, :with_confidence_score, commentable: topic2)
      topic3 = create(:topic, community: community)
      topic3_comment = create(:comment, :with_confidence_score, commentable: topic3)
      topic3_comment = create(:comment, :with_confidence_score, commentable: topic3)

      visit community_path(community, order: :most_commented)

      expect(topic3.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic1.title)

      visit community_path(community, order: :oldest)

      expect(topic1.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic3.title)

      visit community_path(community, order: :newest)

      expect(topic3.title).to appear_before(topic2.title)
      expect(topic2.title).to appear_before(topic1.title)
    end

    scenario "Should order by newest when order param is invalid" do
      proposal = create(:proposal)
      community = proposal.community
      topic1 = create(:topic, community: community)
      topic2 = create(:topic, community: community)

      visit community_path(community, order: "invalid_param")

      expect(topic2.title).to appear_before(topic1.title)
    end

    scenario "Should display topic edit button on topic show when author is logged" do
      proposal = create(:proposal)
      community = proposal.community
      user = create(:user)
      topic1 = create(:topic, community: community, author: user)
      topic2 = create(:topic, community: community)
      login_as(user)

      visit community_topic_path(community, topic1)
      expect(page).to have_link("Edit topic", href: edit_community_topic_path(community, topic1))

      visit community_topic_path(community, topic2)
      expect(page).not_to have_link("Edit topic", href: edit_community_topic_path(community, topic2))
    end

    scenario "Should display participant when there is topics" do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)

      visit community_path(community)

      within ".community-tabs" do
        expect(page).to have_content "Participants (2)"
        expect(page).to have_content topic.author.name
        expect(page).to have_content proposal.author.name
      end
    end

    scenario "Should display participants when there are topics and comments" do
      proposal = create(:proposal)
      community = proposal.community
      topic = create(:topic, community: community)
      comment = create(:comment, commentable: topic)

      visit community_path(community)

      within ".community-tabs" do
        expect(page).to have_content "Participants (3)"
        expect(page).to have_content topic.author.name
        expect(page).to have_content comment.author.name
        expect(page).to have_content proposal.author.name
      end
    end

    scenario "Should redirect root path when communities are disabled" do
      Setting["feature.community"] = nil
      proposal = create(:proposal)
      community = proposal.community

      visit community_path(community)

      expect(page).to have_current_path(root_path)
    end

    scenario "Accesing a community without associated communitable" do
      proposal = create(:proposal)
      community = proposal.community
      proposal.really_destroy!
      community.reload

      expect { visit community_path(community) }.to raise_error(ActionController::RoutingError)
    end

    scenario "does not render district proposals tab for real proposals", :js do
      geozone = create(:geozone)
      proposal = create(:proposal, geozone: geozone)

      visit community_path(proposal.community)

      expect(page).not_to have_link text: "District proposals"
    end

    scenario "renders district proposals tab for proposals with comunity_hide", :js do
      geozone = create(:geozone)
      create(:proposal, geozone: geozone)
      fake_proposal = create(:proposal, geozone: geozone, comunity_hide: true)

      visit community_path(fake_proposal.community)

      expect(page).to have_link "District proposals (1)"
    end

    context "District proposals tab", :js do
      let(:geozone) { create(:geozone) }
      let(:fake_proposal) { create(:proposal, comunity_hide: true, geozone: geozone) }

      scenario "shows empty message when district does not have any proposals" do
        visit community_path(fake_proposal.community)

        click_link "District proposals (0)"

        expect(page).to have_content "There are no proposals in the #{geozone.name} district."
      end

      scenario "shows paginated proposals when there are more than the defined per page" do
        allow(Proposal).to receive(:default_per_page).and_return(2)
        proposals = create_list(:proposal, 3, geozone: geozone)
        visit community_path(fake_proposal.community)
        click_link "District proposals (3)"

        within "li.is-active" do
          expect(page).to have_link "District proposals (3)"
        end
        expect(page).to have_content proposals.first.title
        expect(page).to have_content proposals[Proposal.default_per_page - 1].title
        expect(page).not_to have_content proposals.last.title
        expect(page).to have_css "ul.pagination"

        click_link "Next"

        expect(page).to have_content proposals.last.title
      end

      scenario "shows oldest proposals first" do
        create(:proposal, title: "Older proposal", geozone: geozone, created_at: 2.day.ago)
        create(:proposal, title: "Newer proposal", geozone: geozone, created_at: 1.day.ago)

        visit community_path(fake_proposal.community, anchor: "tab-proposals")

        expect("Older proposal").to appear_before("Newer proposal")
      end

      scenario "does not show proposals with community hide" do
        create(:proposal, title: "Older proposal", geozone: geozone)
        create(:proposal, title: "Newer proposal", geozone: geozone, created_at: 1.day.ago)

        visit community_path(fake_proposal.community, anchor: "tab-proposals")

        within ".proposals-list" do
          expect(page).not_to have_content(fake_proposal.title)
        end
      end
    end
  end
end
