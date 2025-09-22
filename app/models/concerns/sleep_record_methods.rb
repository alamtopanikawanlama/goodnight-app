module SleepRecordMethods
  extend ActiveSupport::Concern

  included do
    validates :clock_in_at, presence: true
    validate :clock_out_after_clock_in

    scope :completed, -> { where.not(clock_out_at: nil) }
    scope :ongoing, -> { where(clock_out_at: nil) }
  end

  def duration_in_hours
    return nil unless clock_out_at
    (clock_out_at - clock_in_at) / 1.hour
  end

  def completed?
    clock_out_at.present?
  end

  private

  def clock_out_after_clock_in
    return unless clock_out_at && clock_in_at
    
    if clock_out_at <= clock_in_at
      errors.add(:clock_out_at, "must be after clock in time")
    end
  end
end
