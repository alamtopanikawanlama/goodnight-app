require 'rails_helper'

RSpec.describe SleepRecordSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, :with_clock_out, user: user) }

  describe 'serialization' do
    let(:serializer) { SleepRecordSerializer.new(sleep_record) }
    let(:serialized_data) { JSON.parse(serializer.to_json) }

    it 'includes all expected attributes' do
      expect(serialized_data).to include(
        'id' => sleep_record.id,
        'clock_in_at' => sleep_record.clock_in_at.as_json,
        'clock_out_at' => sleep_record.clock_out_at.as_json,
        'created_at' => sleep_record.created_at.as_json,
        'updated_at' => sleep_record.updated_at.as_json
      )
    end

    it 'includes calculated fields' do
      expect(serialized_data['duration_in_hours']).to eq(sleep_record.duration_in_hours)
      expect(serialized_data['completed']).to eq(sleep_record.completed?)
    end

    it 'includes user association' do
      expect(serialized_data).to have_key('user')
      expect(serialized_data['user']['id']).to eq(user.id)
      expect(serialized_data['user']['name']).to eq(user.name)
    end
  end

  describe 'with ongoing sleep record' do
    let(:ongoing_record) { create(:sleep_record, user: user, clock_out_at: nil) }
    let(:serializer) { SleepRecordSerializer.new(ongoing_record) }
    let(:serialized_data) { JSON.parse(serializer.to_json) }

    it 'handles nil clock_out_at' do
      expect(serialized_data['clock_out_at']).to be_nil
      expect(serialized_data['duration_in_hours']).to be_nil
      expect(serialized_data['completed']).to be false
    end
  end
end
