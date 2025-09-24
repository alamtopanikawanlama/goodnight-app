class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in_at, :clock_out_at, :duration_in_hours, :completed, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer

  def duration_in_hours
    object.duration_in_hours
  end

  def completed
    object.completed?
  end
end
