FactoryBot.define do
  factory :sleep_record do
    association :user
    clock_in_at { 8.hours.ago }
    clock_out_at { nil } # Clock out time can be nil initially
    
    trait :with_clock_out do
      clock_out_at { 1.hour.ago }
    end
  end
end
