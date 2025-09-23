require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:follower) { create(:user) }
  
  before do
    follower.follow(user)
    user.follow(follower)
  end

  describe 'serialization' do
    let(:serializer) { UserSerializer.new(user) }
    let(:serialized_data) { JSON.parse(serializer.to_json) }

    it 'includes basic attributes' do
      expect(serialized_data).to include(
        'id' => user.id,
        'name' => user.name,
        'created_at' => user.created_at.as_json,
        'updated_at' => user.updated_at.as_json
      )
    end

    it 'includes followers and following counts' do
      expect(serialized_data['followers_count']).to eq(1)
      expect(serialized_data['following_count']).to eq(1)
    end

    it 'does not include followers and following by default' do
      expect(serialized_data).not_to have_key('followers')
      expect(serialized_data).not_to have_key('following')
    end
  end

  describe 'with include options' do
    context 'when including followers' do
      let(:serializer) { UserSerializer.new(user, include: [:followers]) }
      let(:serialized_data) { JSON.parse(serializer.to_json) }

      it 'includes followers' do
        expect(serialized_data).to have_key('followers')
        expect(serialized_data['followers']).to be_an(Array)
        expect(serialized_data['followers'].first['id']).to eq(follower.id)
      end
    end

    context 'when including following' do
      let(:serializer) { UserSerializer.new(user, include: [:following]) }
      let(:serialized_data) { JSON.parse(serializer.to_json) }

      it 'includes following' do
        expect(serialized_data).to have_key('following')
        expect(serialized_data['following']).to be_an(Array)
        expect(serialized_data['following'].first['id']).to eq(follower.id)
      end
    end
  end
end
