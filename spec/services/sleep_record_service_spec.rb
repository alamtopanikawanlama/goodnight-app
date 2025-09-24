require 'rails_helper'

RSpec.describe SleepRecordService, type: :service do
  let(:user) { create(:user) }

  describe '.find_all_by_user' do
    let!(:sleep_records) { create_list(:sleep_record, 3, user: user) }

    it 'returns all sleep records for user successfully' do
      result = SleepRecordService.find_all_by_user(user.id)
      
      expect(result.success?).to be true
      expect(result.data.count).to eq(3)
    end

    it 'returns paginated sleep records when page is provided' do      
      result = SleepRecordService.find_all_by_user(user.id, page: 1, per_page: 2)
      
      expect(result.success?).to be true
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.find_all_by_user('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.find_by_id' do
    let(:sleep_record) { create(:sleep_record, user: user) }

    it 'returns sleep record successfully when found' do
      result = SleepRecordService.find_by_id(user.id, sleep_record.id)
      
      expect(result.success?).to be true
      expect(result.data).to eq(sleep_record)
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.find_by_id('non-existent-id', sleep_record.id)
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end

    it 'returns failure when sleep record not found' do
      result = SleepRecordService.find_by_id(user.id, 'non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find SleepRecord")
    end
  end

  describe '.clock_in' do
    it 'clocks in user successfully' do
      result = SleepRecordService.clock_in(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to be_a(SleepRecord)
      expect(result.message).to eq('Successfully clocked in')
    end

    it 'returns failure when user already has ongoing sleep record' do
      user.clock_in # First clock in
      result = SleepRecordService.clock_in(user.id)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to clock in. User might already have an ongoing sleep record.')
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.clock_in('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.clock_out' do
    before { user.clock_in }

    it 'clocks out user successfully' do
      result = SleepRecordService.clock_out(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to be_a(SleepRecord)
      expect(result.data.completed?).to be true
      expect(result.message).to eq('Successfully clocked out')
    end

    it 'returns failure when no ongoing sleep record' do
      user.clock_out # Clock out first
      result = SleepRecordService.clock_out(user.id)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to clock out. No ongoing sleep record found.')
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.clock_out('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.get_current' do
    it 'returns current sleep record when exists' do
      user.clock_in
      result = SleepRecordService.get_current(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to be_a(SleepRecord)
      expect(result.data.completed?).to be false
    end

    it 'returns failure when no current sleep record' do
      result = SleepRecordService.get_current(user.id)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('No ongoing sleep record found')
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.get_current('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.get_friends_records' do
    let(:friend) { create(:user) }
    let!(:friend_record) { create(:sleep_record, :with_clock_out, user: friend) }

    before { user.follow(friend) }

    it 'returns friends sleep records successfully' do
      result = SleepRecordService.get_friends_records(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to include(friend_record)
    end

    it 'returns paginated friends records when page is provided' do
      result = SleepRecordService.get_friends_records(user.id, page: 1, per_page: 2)
      
      expect(result.success?).to be true
      expect(result.meta[:current_page]).to eq(1)
      expect(result.meta[:per_page]).to eq(2)
      expect(result.meta[:total_pages]).to eq(1)
      expect(result.meta[:total_count]).to eq(1)
      expect(result.data).to include(friend_record)
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.get_friends_records('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.destroy' do
    let(:sleep_record) { create(:sleep_record, user: user) }

    it 'deletes sleep record successfully' do
      result = SleepRecordService.destroy(user.id, sleep_record.id)
      
      expect(result.success?).to be true
      expect(result.message).to eq('Sleep record deleted successfully')
      expect { SleepRecord.find(sleep_record.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns failure when user not found' do
      result = SleepRecordService.destroy('non-existent-id', sleep_record.id)
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end

    it 'returns failure when sleep record not found' do
      result = SleepRecordService.destroy(user.id, 'non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find SleepRecord")
    end
  end
end
