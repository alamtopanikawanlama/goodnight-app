require 'rails_helper'

RSpec.describe FollowService, type: :service do
  describe '.find_all' do
    let!(:follows) { create_list(:follow, 3) }
    let(:params) {
      { page: 1, per_page: 2 }
    }

    it 'returns all follows successfully' do
      result = FollowService.find_all
      
      expect(result.success?).to be true
      expect(result.data.count).to eq(3)
    end

    it 'returns paginated follows when page is provided' do
      allow(Follow).to receive_message_chain(:includes, :page, :per).and_return(follows)
      
      result = FollowService.find_all(params)
      
      expect(result.success?).to be true
      expect(result.data.count).to eq(2)
      expect(result.meta[:current_page]).to eq(1)
      expect(result.meta[:per_page]).to eq(2)
      expect(result.meta[:total_count]).to eq(3)
      expect(result.meta[:total_pages]).to eq(2)
    end
  end

  describe '.find_by_id' do
    let(:follow) { create(:follow) }

    it 'returns follow successfully when found' do
      result = FollowService.find_by_id(follow.id)
      
      expect(result.success?).to be true
      expect(result.data).to eq(follow)
    end

    it 'returns failure when follow not found' do
      result = FollowService.find_by_id('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find Follow")
    end
  end

  describe '.create' do
    let(:follower) { create(:user) }
    let(:following) { create(:user) }
    let(:valid_params) { { follower_id: follower.id, following_id: following.id } }
    let(:invalid_params) { { follower_id: follower.id, following_id: follower.id } }

    it 'creates follow successfully with valid params' do
      result = FollowService.create(valid_params)
      
      expect(result.success?).to be true
      expect(result.data).to be_a(Follow)
      expect(result.data.follower).to eq(follower)
      expect(result.data.following).to eq(following)
      expect(result.message).to eq('Follow relationship created successfully')
    end

    it 'returns failure with invalid params (self follow)' do
      result = FollowService.create(invalid_params)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to create follow relationship')
      expect(result.errors).to include("Following cannot follow yourself")
    end

    it 'returns failure with duplicate follow' do
      create(:follow, follower: follower, following: following)
      result = FollowService.create(valid_params)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to create follow relationship')
      expect(result.errors).to include("Follower has already been taken")
    end
  end

  describe '.destroy' do
    let(:follow) { create(:follow) }

    it 'deletes follow successfully' do
      result = FollowService.destroy(follow.id)
      
      expect(result.success?).to be true
      expect(result.message).to eq('Follow relationship deleted successfully')
      expect { Follow.find(follow.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns failure when follow not found' do
      result = FollowService.destroy('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find Follow")
    end
  end
end
