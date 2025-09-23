require 'rails_helper'

RSpec.describe UserService, type: :service do
  describe '.find_all' do
    let!(:users) { create_list(:user, 3) }
    let(:params) {
      { page: 1, per_page: 2 }
    }

    it 'returns all users successfully' do
      result = UserService.find_all
      
      expect(result.success?).to be true
      expect(result.data.count).to eq(3)
    end

    it 'returns paginated users when page is provided' do
      result = UserService.find_all(params)

      expect(result.success?).to be true
      expect(result.data.count).to eq(2)
      expect(result.meta[:current_page]).to eq(1)
      expect(result.meta[:per_page]).to eq(2)
      expect(result.meta[:total_count]).to eq(3)
      expect(result.meta[:total_pages]).to eq(2)
    end
  end

  describe '.find_by_id' do
    let(:user) { create(:user) }

    it 'returns user successfully when found' do
      result = UserService.find_by_id(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to eq(user)
    end

    it 'returns failure when user not found' do
      result = UserService.find_by_id('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.create' do
    let(:valid_params) { { name: 'Test User' } }
    let(:invalid_params) { { name: '' } }

    it 'creates user successfully with valid params' do
      result = UserService.create(valid_params)
      
      expect(result.success?).to be true
      expect(result.data).to be_a(User)
      expect(result.data.name).to eq('Test User')
      expect(result.message).to eq('User created successfully')
    end

    it 'returns failure with invalid params' do
      result = UserService.create(invalid_params)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to create user')
      expect(result.errors).to include("Name can't be blank")
    end
  end

  describe '.update' do
    let(:user) { create(:user) }
    let(:valid_params) { { name: 'Updated Name' } }
    let(:invalid_params) { { name: '' } }

    it 'updates user successfully with valid params' do
      result = UserService.update(user.id, valid_params)
      
      expect(result.success?).to be true
      expect(result.data.name).to eq('Updated Name')
      expect(result.message).to eq('User updated successfully')
    end

    it 'returns failure with invalid params' do
      result = UserService.update(user.id, invalid_params)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to update user')
      expect(result.errors).to include("Name can't be blank")
    end

    it 'returns failure when user not found' do
      result = UserService.update('non-existent-id', valid_params)
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.destroy' do
    let(:user) { create(:user) }

    it 'deletes user successfully' do
      result = UserService.destroy(user.id)
      
      expect(result.success?).to be true
      expect(result.message).to eq('User deleted successfully')
      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns failure when user not found' do
      result = UserService.destroy('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.follow_user' do
    let(:follower) { create(:user) }
    let(:target_user) { create(:user) }

    it 'follows user successfully' do
      result = UserService.follow_user(follower.id, target_user.id)
      
      expect(result.success?).to be true
      expect(result.message).to eq('Successfully followed user')
      expect(follower.reload.following?(target_user)).to be true
    end

    it 'returns failure when trying to follow self' do
      result = UserService.follow_user(follower.id, follower.id)
      
      expect(result.failure?).to be true
      expect(result.message).to eq('Failed to follow user')
    end

    it 'returns failure when user not found' do
      result = UserService.follow_user('non-existent-id', target_user.id)
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.unfollow_user' do
    let(:follower) { create(:user) }
    let(:target_user) { create(:user) }

    before { follower.follow(target_user) }

    it 'unfollows user successfully' do
      result = UserService.unfollow_user(follower.id, target_user.id)
      
      expect(result.success?).to be true
      expect(result.message).to eq('Successfully unfollowed user')
      expect(follower.reload.following?(target_user)).to be false
    end

    it 'returns failure when user not found' do
      result = UserService.unfollow_user('non-existent-id', target_user.id)
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.get_followers' do
    let(:user) { create(:user) }
    let(:follower) { create(:user) }

    before { follower.follow(user) }

    it 'returns user followers successfully' do
      result = UserService.get_followers(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to include(follower)
    end

    it 'returns failure when user not found' do
      result = UserService.get_followers('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end

  describe '.get_following' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { user.follow(target_user) }

    it 'returns users being followed successfully' do
      result = UserService.get_following(user.id)
      
      expect(result.success?).to be true
      expect(result.data).to include(target_user)
    end

    it 'returns failure when user not found' do
      result = UserService.get_following('non-existent-id')
      
      expect(result.failure?).to be true
      expect(result.message).to include("Couldn't find User")
    end
  end
end
