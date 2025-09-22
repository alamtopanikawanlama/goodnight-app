require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:following).class_name('User') }
  end

  describe 'validations' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    
    before do
      create(:follow, follower: user1, following: user2)
    end

    it { should validate_uniqueness_of(:follower_id).scoped_to(:following_id).ignoring_case_sensitivity }

    it 'validates that user cannot follow themselves' do
      follow = build(:follow, follower: user1, following: user1)
      expect(follow).to_not be_valid
      expect(follow.errors[:following]).to include("cannot follow yourself")
    end

    it 'allows different users to follow each other' do
      user3 = create(:user)
      follow = build(:follow, follower: user2, following: user3)
      expect(follow).to be_valid
    end

    it 'prevents duplicate follows' do
      duplicate_follow = build(:follow, follower: user1, following: user2)
      expect(duplicate_follow).to_not be_valid
      expect(duplicate_follow.errors[:follower_id]).to include("has already been taken")
    end
  end
end
