require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:clock_in_at) }

    describe 'clock_out_after_clock_in validation' do
      let(:sleep_record) { build(:sleep_record, clock_in_at: 2.hours.ago) }

      it 'is valid when clock_out_at is after clock_in_at' do
        sleep_record.clock_out_at = 1.hour.ago
        expect(sleep_record).to be_valid
      end

      it 'is invalid when clock_out_at is before clock_in_at' do
        sleep_record.clock_out_at = 3.hours.ago
        expect(sleep_record).to_not be_valid
        expect(sleep_record.errors[:clock_out_at]).to include("must be after clock in time")
      end

      it 'is invalid when clock_out_at equals clock_in_at' do
        sleep_record.clock_out_at = sleep_record.clock_in_at
        expect(sleep_record).to_not be_valid
        expect(sleep_record.errors[:clock_out_at]).to include("must be after clock in time")
      end

      it 'is valid when clock_out_at is nil' do
        sleep_record.clock_out_at = nil
        expect(sleep_record).to be_valid
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:completed_record) { create(:sleep_record, :with_clock_out, user: user) }
    let!(:ongoing_record) { create(:sleep_record, user: user, clock_out_at: nil) }

    describe '.completed' do
      it 'returns only completed sleep records' do
        expect(SleepRecord.completed).to include(completed_record)
        expect(SleepRecord.completed).not_to include(ongoing_record)
      end
    end

    describe '.ongoing' do
      it 'returns only ongoing sleep records' do
        expect(SleepRecord.ongoing).to include(ongoing_record)
        expect(SleepRecord.ongoing).not_to include(completed_record)
      end
    end
  end

  describe 'instance methods' do
    describe '#duration_in_hours' do
      context 'when clock_out_at is present' do
        it 'returns duration in hours' do
          freeze_time do
            clock_in_time = Time.current
            clock_out_time = clock_in_time + 2.hours
            
            sleep_record = build(:sleep_record, clock_in_at: clock_in_time, clock_out_at: clock_out_time)
            expect(sleep_record.duration_in_hours).to eq(2.0)
          end
        end
      end

      context 'when clock_out_at is nil' do
        it 'returns nil' do
          sleep_record = build(:sleep_record, clock_out_at: nil)
          expect(sleep_record.duration_in_hours).to be_nil
        end
      end
    end

    describe '#completed?' do
      let(:sleep_record) { build(:sleep_record) }

      it 'returns true when clock_out_at is present' do
        sleep_record.clock_out_at = 1.hour.ago
        expect(sleep_record.completed?).to be true
      end

      it 'returns false when clock_out_at is nil' do
        sleep_record.clock_out_at = nil
        expect(sleep_record.completed?).to be false
      end
    end
  end
end
