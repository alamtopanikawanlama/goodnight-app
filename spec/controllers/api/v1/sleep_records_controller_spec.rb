require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user, clock_out_at: Time.now) }

  describe 'GET #index' do
    let!(:sleep_records) do
      [
        create(:sleep_record, user: user, clock_in_at: 3.days.ago, clock_out_at: 3.days.ago + 8.hours),
        create(:sleep_record, user: user, clock_in_at: 2.days.ago, clock_out_at: 2.days.ago + 7.hours),
        create(:sleep_record, user: user, clock_in_at: 1.day.ago, clock_out_at: 1.day.ago + 6.hours)
      ]
    end

    it 'returns success response' do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['sleep_records'].count).to eq(3)
    end

    it 'filters by start_date and end_date' do
      get :index, params: {
        user_id: user.id,
        start_date: 2.days.ago.to_date.to_s,
        end_date: 1.day.ago.to_date.to_s
      }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      dates = json_response['sleep_records'].map { |r| Date.parse(r['clock_in_at']) }
      expect(dates).to all(be >= 2.days.ago.to_date)
      expect(dates).to all(be <= 1.day.ago.to_date)
    end

    it 'passes pagination parameters' do
      get :index, params: { user_id: user.id, page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('sleep_records')
      expect(json_response).to have_key('pagination')
      expect(json_response['pagination'].keys).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end

    context 'when user not found' do
      before do
        allow(SleepRecordService).to receive(:find_all_by_user).and_return(
          ServiceResult.new(success: false, message: 'User not found')
        )
      end

      it 'returns not found response' do
        get :index, params: { user_id: 'non-existent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #show' do
    context 'when sleep record exists' do
      it 'returns success response' do
        get :show, params: { user_id: user.id, id: sleep_record.id }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when sleep record does not exist' do
      it 'returns not found response' do
        get :show, params: { user_id: user.id, id: 'non-existent' }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #clock_in' do
    context 'when clock in is successful' do
      it 'clocks in user successfully' do
        post :clock_in, params: { user_id: user.id }
        expect(response).to have_http_status(:created)
      end
    end

    context 'when clock in fails' do
      before do
        allow(SleepRecordService).to receive(:clock_in).and_return(
          ServiceResult.new(success: false, message: 'Already clocked in')
        )
      end

      it 'returns bad request response' do
        post :clock_in, params: { user_id: user.id }
        
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['message']).to eq('Already clocked in')
      end
    end
  end

  describe 'POST #clock_out' do
    context 'when clock out is successful' do
      before do
        create(:sleep_record, user: user, clock_out_at: nil)
      end

      it 'clocks out user successfully' do
        post :clock_out, params: { user_id: user.id }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when clock out fails' do
      before do
        allow(SleepRecordService).to receive(:clock_in).and_return(
          ServiceResult.new(success: false, message: 'Already clocked out')
        )
      end

      it 'returns bad request response' do
        post :clock_out, params: { user_id: user.id }
        
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET #current' do
    context 'when current sleep record exists' do
      before do
        create(:sleep_record, user: user, clock_out_at: nil)
      end

      it 'returns current sleep record' do
        get :current, params: { user_id: user.id }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no current sleep record' do
      it 'returns not found response' do
        get :current, params: { user_id: user.id }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #friends' do
    let(:friend_user) { create(:user) }

    before do
      create(:sleep_record, user: friend_user, clock_in_at: 2.days.ago, clock_out_at: 2.days.ago + 7.hours)
      create(:sleep_record, user: friend_user, clock_in_at: 1.day.ago, clock_out_at: 1.day.ago + 6.hours)
      create(:follow, follower: user, following: friend_user)
    end

    it 'returns friends sleep records' do
      get :friends, params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['friends_sleep_records'].count).to eq(2)
    end

    it 'filters friends records by start_date and end_date' do
      get :friends, params: {
        user_id: user.id,
        start_date: 2.days.ago.to_date.to_s,
        end_date: 1.day.ago.to_date.to_s
      }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      dates = json_response['friends_sleep_records'].map { |r| Date.parse(r['clock_in_at']) }
      expect(dates).to all(be >= 2.days.ago.to_date)
      expect(dates).to all(be <= 1.day.ago.to_date)
    end

    it 'passes pagination parameters' do
      get :friends, params: { user_id: user.id, page: 1, per_page: 5 }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('friends_sleep_records')
      expect(json_response).to have_key('pagination')
      expect(json_response['pagination'].keys).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end
  end

  describe 'DELETE #destroy' do
    context 'when deletion is successful' do
      it 'deletes sleep record successfully' do
        delete :destroy, params: { user_id: user.id, id: sleep_record.id }
        
        expect(response).to have_http_status(204)
      end
    end

    context 'when deletion fails' do
      it 'returns not found response' do
        delete :destroy, params: { user_id: user.id, id: 'non-existent' }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
