class SleepRecord < ApplicationRecord
  include SleepRecordMethods
  
  belongs_to :user
end
