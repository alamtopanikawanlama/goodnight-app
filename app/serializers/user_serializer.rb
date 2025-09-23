class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :followers_count, :following_count

  has_many :followers, serializer: UserSerializer, if: :include_followers?
  has_many :following, serializer: UserSerializer, if: :include_following?

  def followers_count
    object.followers.count
  end

  def following_count
    object.following.count
  end

  def include_followers?
    instance_options[:include]&.include?(:followers)
  end

  def include_following?
    instance_options[:include]&.include?(:following)
  end
end
