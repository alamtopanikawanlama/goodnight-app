module UserMethods
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true, uniqueness: true
  end

  # Following/Follower methods
  def follow(other_user)
    return false if self == other_user
    following << other_user unless following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  # Sleep tracking methods
  def clock_in
    return false if current_sleep_record.present?
    sleep_records.create(clock_in_at: Time.current)
  end

  def clock_out
    current_record = current_sleep_record
    return false unless current_record
    current_record.update(clock_out_at: Time.current)
  end

  def friends_sleep_records
    SleepRecord.joins(:user)
               .where(user: following)
               .where.not(clock_out_at: nil)
               .includes(:user)
               .order(created_at: :desc)
  end

  private

  def current_sleep_record
    sleep_records.ongoing.last
  end
end
