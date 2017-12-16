require 'rails_helper'

feature 'Social media meta tags' do

  context 'Setting social media meta tags' do

    let(:meta_keywords) { 'citizen, participation, open government' }
    let(:meta_title) { 'Decide Madrid' }
    let(:meta_description) { 'Citizen Participation and Open Government Application' }
    let(:twitter_handle) { '@decidemadrid' }
    let(:url) { 'http://example.com' }
    let(:facebook_handle) { 'decidemadrid' }
    let(:org_name) { 'Decide Madrid' }

    before do
      Setting['meta_keywords'] = meta_keywords
      Setting['meta_title'] = meta_title
      Setting['meta_description'] = meta_description
      Setting['twitter_handle'] = twitter_handle
      Setting['url'] = url
      Setting['facebook_handle'] = facebook_handle
      Setting['org_name'] = org_name
    end

    after do
      Setting['meta_keywords'] = nil
      Setting['meta_title'] = nil
      Setting['meta_description'] = nil
      Setting['twitter_handle'] = nil
      Setting['url'] = 'http://example.com'
      Setting['facebook_handle'] = nil
      Setting['org_name'] = 'Decide Madrid'
    end

    scenario 'Social media meta tags partial render settings content' do

      visit root_path

      expect(page).to have_css 'meta[name="keywords"][content="' + meta_keywords + '"]', visible: false
      expect(page).to have_css 'meta[name="twitter:site"][content="' + twitter_handle + '"]', visible: false
      expect(page).to have_css 'meta[name="twitter:title"][content="' + meta_title + '"]', visible: false
      expect(page).to have_css 'meta[name="twitter:description"][content="' + meta_description + '"]', visible: false
      expect(page).to have_css 'meta[name="twitter:image"][content="http://www.example.com/social_media_icon_twitter.png"]', visible: false
      expect(page).to have_css 'meta[property="og:title"][content="' + meta_title + '"]', visible: false
      expect(page).to have_css 'meta[property="article:publisher"][content="' + url + '"]', visible: false
      expect(page).to have_css 'meta[property="article:author"][content="https://www.facebook.com/' + facebook_handle + '"]', visible: false
      expect(page).to have_css 'meta[property="og:url"][content="http://www.example.com/"]', visible: false
      expect(page).to have_css 'meta[property="og:image"][content="http://www.example.com/social_media_icon.png"]', visible: false
      expect(page).to have_css 'meta[property="og:site_name"][content="' + org_name + '"]', visible: false
      expect(page).to have_css 'meta[property="og:description"][content="' + meta_description + '"]', visible: false
    end
  end

end
