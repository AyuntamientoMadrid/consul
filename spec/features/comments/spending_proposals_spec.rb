require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting spending_proposals' do
  let(:user)   { create :user }
  let(:spending_proposal) { create :spending_proposal }

  background do
    skip 'Spending Proposals now redirects to its associated Budget Investment'

    Setting["feature.spending_proposals"] = true
    Setting['feature.spending_proposal_features.voting_allowed'] = true
  end

  scenario 'Index' do
    3.times { create(:comment, commentable: spending_proposal) }

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_css('.comment', count: 3)

    comment = Comment.last
    within first('.comment') do
      expect(page).to have_content comment.user.name
      expect(page).to have_content I18n.l(comment.created_at, format: :datetime)
      expect(page).to have_content comment.body
    end
  end

  scenario 'Show' do
    parent_comment = create(:comment, commentable: spending_proposal)
    first_child    = create(:comment, commentable: spending_proposal, parent: parent_comment)
    second_child   = create(:comment, commentable: spending_proposal, parent: parent_comment)

    visit comment_path(parent_comment)

    expect(page).to have_css(".comment", count: 3)
    expect(page).to have_content parent_comment.body
    expect(page).to have_content first_child.body
    expect(page).to have_content second_child.body

    expect(page).to have_link "Go back to #{spending_proposal.title}", href: spending_proposal_path(spending_proposal)
  end

  scenario 'Collapsable comments', :js do
    parent_comment = create(:comment, body: "Main comment", commentable: spending_proposal)
    child_comment  = create(:comment, body: "First subcomment", commentable: spending_proposal, parent: parent_comment)
    grandchild_comment = create(:comment, body: "Last subcomment", commentable: spending_proposal, parent: child_comment)

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_css('.comment', count: 3)

    find("#comment_#{child_comment.id}_children_arrow").click

    expect(page).to have_css('.comment', count: 2)
    expect(page).not_to have_content grandchild_comment.body

    find("#comment_#{child_comment.id}_children_arrow").click

    expect(page).to have_css('.comment', count: 3)
    expect(page).to have_content grandchild_comment.body

    find("#comment_#{parent_comment.id}_children_arrow").click

    expect(page).to have_css('.comment', count: 1)
    expect(page).not_to have_content child_comment.body
    expect(page).not_to have_content grandchild_comment.body
  end

  scenario 'Comment order' do
    c1 = create(:comment, :with_confidence_score, commentable: spending_proposal, cached_votes_up: 100, cached_votes_total: 120, created_at: Time.now - 2)
    c2 = create(:comment, :with_confidence_score, commentable: spending_proposal, cached_votes_up: 10, cached_votes_total: 12, created_at: Time.now - 1)
    c3 = create(:comment, :with_confidence_score, commentable: spending_proposal, cached_votes_up: 1, cached_votes_total: 2, created_at: Time.now)

    visit spending_proposal_path(spending_proposal, order: :most_voted)

    expect(c1.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c3.body)

    visit spending_proposal_path(spending_proposal, order: :newest)

    expect(c3.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c1.body)

    visit spending_proposal_path(spending_proposal, order: :oldest)

    expect(c1.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c3.body)
  end

  scenario 'Creation date works differently in roots and in child comments, when sorting by confidence_score' do
   old_root = create(:comment, commentable: spending_proposal, created_at: Time.now - 10)
   new_root = create(:comment, commentable: spending_proposal, created_at: Time.now)
   old_child = create(:comment, commentable: spending_proposal, parent_id: new_root.id, created_at: Time.now - 10)
   new_child = create(:comment, commentable: spending_proposal, parent_id: new_root.id, created_at: Time.now)

   visit spending_proposal_path(spending_proposal, order: :most_voted)

   expect(new_root.body).to appear_before(old_root.body)
   expect(old_child.body).to appear_before(new_child.body)

   visit spending_proposal_path(spending_proposal, order: :newest)

   expect(new_root.body).to appear_before(old_root.body)
   expect(new_child.body).to appear_before(old_child.body)

   visit spending_proposal_path(spending_proposal, order: :oldest)

   expect(old_root.body).to appear_before(new_root.body)
   expect(old_child.body).to appear_before(new_child.body)
  end

  scenario 'Turns links into html links' do
    create :comment, commentable: spending_proposal, body: 'Built with http://rubyonrails.org/'

    visit spending_proposal_path(spending_proposal)

    within first('.comment') do
      expect(page).to have_content 'Built with http://rubyonrails.org/'
      expect(page).to have_link('http://rubyonrails.org/', href: 'http://rubyonrails.org/')
      expect(find_link('http://rubyonrails.org/')[:rel]).to eq('nofollow')
      expect(find_link('http://rubyonrails.org/')[:target]).to eq('_blank')
    end
  end

  scenario 'Sanitizes comment body for security' do
    create :comment, commentable: spending_proposal, body: "<script>alert('hola')</script> <a href=\"javascript:alert('sorpresa!')\">click me<a/> http://madrid.es"

    visit spending_proposal_path(spending_proposal)

    within first('.comment') do
      expect(page).to have_content "click me http://madrid.es"
      expect(page).to have_link('http://madrid.es', href: 'http://madrid.es')
      expect(page).not_to have_link('click me')
    end
  end

  scenario 'Paginated comments' do
    per_page = 10
    (per_page + 2).times { create(:comment, commentable: spending_proposal)}

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_css('.comment', count: per_page)
    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_css('.comment', count: 2)
  end

  feature 'Not logged user' do
    scenario 'can not see comments forms' do
      create(:comment, commentable: spending_proposal)
      visit spending_proposal_path(spending_proposal)

      expect(page).to have_content 'You must Sign in or Sign up to leave a comment'
      within('#comments') do
        expect(page).not_to have_content 'Write a comment'
        expect(page).not_to have_content 'Reply'
      end
    end
  end

  scenario 'Create', :js do
    login_as(user)
    visit spending_proposal_path(spending_proposal)

    fill_in "comment-body-spending_proposal_#{spending_proposal.id}", with: 'Have you thought about...?'
    click_button 'Publish comment'

    within "#comments" do
      expect(page).to have_content 'Have you thought about...?'
      expect(page).to have_content '(1)'
    end
  end

  scenario 'Errors on create', :js do
    login_as(user)
    visit spending_proposal_path(spending_proposal)

    click_button 'Publish comment'

    expect(page).to have_content "Can't be blank"
  end

  scenario 'Reply', :js do
    citizen = create(:user, username: 'Ana')
    manuela = create(:user, username: 'Manuela')
    comment = create(:comment, commentable: spending_proposal, user: citizen)

    login_as(manuela)
    visit spending_proposal_path(spending_proposal)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: 'It will be done next week.'
      click_button 'Publish reply'
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content 'It will be done next week.'
    end

    expect(page).not_to have_selector("#js-comment-form-comment_#{comment.id}", visible: true)
  end

  scenario 'Errors on reply', :js do
    comment = create(:comment, commentable: spending_proposal, user: user)

    login_as(user)
    visit spending_proposal_path(spending_proposal)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button 'Publish reply'
      expect(page).to have_content "Can't be blank"
    end

  end

  scenario "N replies", :js do
    parent = create(:comment, commentable: spending_proposal)

    7.times do
      create(:comment, commentable: spending_proposal, parent: parent)
      parent = parent.children.first
    end

    visit spending_proposal_path(spending_proposal)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

  scenario "Flagging as inappropriate", :js do
    comment = create(:comment, commentable: spending_proposal)

    login_as(user)
    visit spending_proposal_path(spending_proposal)

    within "#comment_#{comment.id}" do
      page.find("#flag-expand-comment-#{comment.id}").click
      page.find("#flag-comment-#{comment.id}").click

      expect(page).to have_css("#unflag-expand-comment-#{comment.id}")
    end

    expect(Flag.flagged?(user, comment)).to be
  end

  scenario "Undoing flagging as inappropriate", :js do
    comment = create(:comment, commentable: spending_proposal)
    Flag.flag(user, comment)

    login_as(user)
    visit spending_proposal_path(spending_proposal)

    within "#comment_#{comment.id}" do
      page.find("#unflag-expand-comment-#{comment.id}").click
      page.find("#unflag-comment-#{comment.id}").click

      expect(page).to have_css("#flag-expand-comment-#{comment.id}")
    end

    expect(Flag.flagged?(user, comment)).not_to be
  end

  scenario "Flagging turbolinks sanity check", :js do
    spending_proposal = create(:spending_proposal, title: "Should we change the world?")
    comment = create(:comment, commentable: spending_proposal)

    login_as(user)
    visit spending_proposals_path
    click_link "Should we change the world?"

    within "#comment_#{comment.id}" do
      page.find("#flag-expand-comment-#{comment.id}").click
      expect(page).to have_selector("#flag-comment-#{comment.id}")
    end
  end

  scenario "Erasing a comment's author" do
    spending_proposal = create(:spending_proposal)
    comment = create(:comment, commentable: spending_proposal, body: "this should be visible")
    comment.user.erase

    visit spending_proposal_path(spending_proposal)
    within "#comment_#{comment.id}" do
      expect(page).to have_content('User deleted')
      expect(page).to have_content('this should be visible')
    end
  end

  feature "Moderators" do
    scenario "can create comment as a moderator", :js do
      moderator = create(:moderator)

      login_as(moderator.user)
      visit spending_proposal_path(spending_proposal)
      fill_in "comment-body-spending_proposal_#{spending_proposal.id}", with: "I am moderating!"
      check "comment-as-moderator-spending_proposal_#{spending_proposal.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end
    end

    scenario "can create reply as a moderator", :js do
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      moderator = create(:moderator, user: manuela)
      comment = create(:comment, commentable: spending_proposal, user: citizen)

      login_as(manuela)
      visit spending_proposal_path(spending_proposal)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "comment-body-comment_#{comment.id}", with: "I am moderating!"
        check "comment-as-moderator-comment_#{comment.id}"
        click_button 'Publish reply'
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end

      expect(page).not_to have_selector("#js-comment-form-comment_#{comment.id}", visible: true)
    end

    scenario "can not comment as an administrator" do
      moderator = create(:moderator)

      login_as(moderator.user)
      visit spending_proposal_path(spending_proposal)

      expect(page).not_to have_content "Comment as administrator"
    end
  end

  feature "Administrators" do
    scenario "can create comment as an administrator", :js do
      admin = create(:administrator)

      login_as(admin.user)
      visit spending_proposal_path(spending_proposal)

      fill_in "comment-body-spending_proposal_#{spending_proposal.id}", with: "I am your Admin!"
      check "comment-as-administrator-spending_proposal_#{spending_proposal.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am your Admin!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end
    end

    scenario "can create reply as an administrator", :js do
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      admin   = create(:administrator, user: manuela)
      comment = create(:comment, commentable: spending_proposal, user: citizen)

      login_as(manuela)
      visit spending_proposal_path(spending_proposal)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "comment-body-comment_#{comment.id}", with: "Top of the world!"
        check "comment-as-administrator-comment_#{comment.id}"
        click_button 'Publish reply'
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Top of the world!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end

      expect(page).not_to have_selector("#js-comment-form-comment_#{comment.id}", visible: true)
    end

    scenario "can not comment as a moderator" do
      admin  = create(:administrator)

      login_as(admin.user)
      visit spending_proposal_path(spending_proposal)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  feature 'Voting comments' do

    background do
      @manuela = create(:user, verified_at: Time.now)
      @pablo = create(:user)
      @spending_proposal = create(:spending_proposal)
      @comment = create(:comment, commentable: @spending_proposal)

      login_as(@manuela)
    end

    scenario 'Show' do
      create(:vote, voter: @manuela, votable: @comment, vote_flag: true)
      create(:vote, voter: @pablo, votable: @comment, vote_flag: false)

      visit spending_proposal_path(@spending_proposal)

      within("#comment_#{@comment.id}_votes") do
        within(".in_favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario 'Create', :js do
      visit spending_proposal_path(@spending_proposal)

      within("#comment_#{@comment.id}_votes") do
        find(".in_favor a").click

        within(".in_favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario 'Update', :js do
      visit spending_proposal_path(@spending_proposal)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.against a').click

        within('.in_favor') do
          expect(page).to have_content "0"
        end

        within('.against') do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario 'Trying to vote multiple times', :js do
      visit spending_proposal_path(@spending_proposal)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.in_favor a').click

        within('.in_favor') do
          expect(page).to have_content "1"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end
  end

end
