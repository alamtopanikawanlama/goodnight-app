module FollowMethods
  extend ActiveSupport::Concern

  included do
    validates :follower_id, uniqueness: { scope: :following_id }
    validate :cannot_follow_self
  end

  private

  def cannot_follow_self
    if follower_id == following_id
      errors.add(:following, "cannot follow yourself")
    end
  end
end
