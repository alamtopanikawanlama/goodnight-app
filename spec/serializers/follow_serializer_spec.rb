require 'rails_helper'

RSpec.describe FollowSerializer, type: :serializer do
  let(:follow) { create(:follow) }

  describe 'serialization' do
    let(:serializer) { FollowSerializer.new(follow) }
    let(:serialized_data) { JSON.parse(serializer.to_json) }

    it 'includes basic attributes' do
      expect(serialized_data).to include(
        'id' => follow.id,
        'created_at' => follow.created_at.as_json,
        'updated_at' => follow.updated_at.as_json
      )
    end

    it 'includes follower association' do
      expect(serialized_data).to have_key('follower')
      expect(serialized_data['follower']['id']).to eq(follow.follower.id)
      expect(serialized_data['follower']['name']).to eq(follow.follower.name)
    end

    it 'includes following association' do
      expect(serialized_data).to have_key('following')
      expect(serialized_data['following']['id']).to eq(follow.following.id)
      expect(serialized_data['following']['name']).to eq(follow.following.name)
    end
  end
end
