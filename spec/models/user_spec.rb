require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it { should have_many(:active_follows).class_name('Follow').with_foreign_key('follower_id').dependent(:destroy) }
    it { should have_many(:passive_follows).class_name('Follow').with_foreign_key('following_id').dependent(:destroy) }
    it { should have_many(:following).through(:active_follows).source(:following) }
    it { should have_many(:followers).through(:passive_follows).source(:follower) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'following methods' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe '#follow' do
      it 'follows another user' do
        expect { user.follow(other_user) }.to change { user.following.count }.by(1)
        expect(user.following?(other_user)).to be true
      end

      it 'does not follow the same user twice' do
        user.follow(other_user)
        expect { user.follow(other_user) }.not_to change { user.following.count }
      end

      it 'returns false when trying to follow self' do
        result = user.follow(user)
        expect(result).to be false
        expect(user.following?(user)).to be false
      end
    end

    describe '#unfollow' do
      before { user.follow(other_user) }

      it 'unfollows a user' do
        expect { user.unfollow(other_user) }.to change { user.following.count }.by(-1)
        expect(user.following?(other_user)).to be false
      end
    end

    describe '#following?' do
      it 'returns true when following a user' do
        user.follow(other_user)
        expect(user.following?(other_user)).to be true
      end

      it 'returns false when not following a user' do
        expect(user.following?(other_user)).to be false
      end
    end
  end

  describe 'sleep tracking methods' do
    let(:user) { create(:user) }

    describe '#clock_in' do
      it 'creates a new sleep record' do
        expect { user.clock_in }.to change { user.sleep_records.count }.by(1)
      end

      it 'sets clock_in_at to current time' do
        freeze_time do
          user.clock_in
          expect(user.sleep_records.last.clock_in_at).to eq(Time.current)
        end
      end

      it 'returns false if user already has an ongoing sleep record' do
        user.clock_in
        result = user.clock_in
        expect(result).to be false
      end
    end

    describe '#clock_out' do
      context 'when user has an ongoing sleep record' do
        before { user.clock_in }

        it 'updates the clock_out_at time' do
          freeze_time do
            user.clock_out
            expect(user.sleep_records.last.clock_out_at).to eq(Time.current)
          end
        end

        it 'returns the updated record' do
          result = user.clock_out
          expect(result).to be_truthy
        end
      end

      context 'when user has no ongoing sleep record' do
        it 'returns false' do
          result = user.clock_out
          expect(result).to be false
        end
      end
    end

    describe '#current_sleep_record' do
      it 'returns nil when no ongoing sleep record' do
        expect(user.send(:current_sleep_record)).to be_nil
      end

      it 'returns the ongoing sleep record' do
        user.clock_in
        expect(user.send(:current_sleep_record)).to eq(user.sleep_records.last)
      end

      it 'returns nil when last sleep record is completed' do
        user.clock_in
        user.clock_out
        expect(user.send(:current_sleep_record)).to be_nil
      end
    end
  end

  describe '#friends_sleep_records' do
    let(:user) { create(:user) }
    let(:friend1) { create(:user) }
    let(:friend2) { create(:user) }
    let(:non_friend) { create(:user) }

    before do
      user.follow(friend1)
      user.follow(friend2)
      
      # Create completed sleep records
      create(:sleep_record, :with_clock_out, user: friend1)
      create(:sleep_record, :with_clock_out, user: friend2)
      create(:sleep_record, :with_clock_out, user: non_friend)
      
      # Create ongoing sleep record (should be excluded)
      create(:sleep_record, user: friend1, clock_out_at: nil)
    end

    it 'returns sleep records from followed users only' do
      friends_records = user.friends_sleep_records
      expect(friends_records.map(&:user)).to match_array([friend1, friend2])
    end

    it 'excludes ongoing sleep records' do
      friends_records = user.friends_sleep_records
      expect(friends_records.all?(&:completed?)).to be true
    end

    it 'orders by created_at desc' do
      friends_records = user.friends_sleep_records
      expect(friends_records.map(&:created_at)).to eq(friends_records.map(&:created_at).sort.reverse)
    end
  end
end
