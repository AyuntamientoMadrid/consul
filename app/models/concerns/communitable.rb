module Communitable
  extend ActiveSupport::Concern

  included do
    belongs_to :community
    before_create :associate_community
    after_destroy :destroy_community
  end

  def associate_community
    community = Community.create
    self.community_id = community.id
  end

  def destroy_community
    if self.really_destroyed?
      Community.find(self.community_id).destroy
    end
  end
end
