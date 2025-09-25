require 'rails_helper'

RSpec.describe Api::V1::SleepRecordsController, type: :controller do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user, clock_out_at: Time.now) }

  describe 'GET #index' do
    let!(:sleep_records) { create_list(:sleep_record, 3, user: user, clock_out_at: Time.now) }

    it 'returns success response' do
      get :index, params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['sleep_records'].count).to eq(3)
      json_response['sleep_records'].each do |record|
        expect(record).to have_key('id')
        expect(record).to have_key('clock_in_at')
        expect(record).to have_key('clock_out_at')
        expect(record).to have_key('duration_in_hours')
        expect(record).to have_key('completed')
        expect(record).to have_key('created_at')
        expect(record).to have_key('updated_at')
        expect(record).to have_key('user')
      end
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
      create_list(:sleep_record, 2, user: friend_user, clock_out_at: Time.now)
      create(:follow, follower: user, following: friend_user)
    end

    it 'returns friends sleep records' do
      get :friends, params: { user_id: user.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['friends_sleep_records'].count).to eq(2)
      json_response['friends_sleep_records'].each do |record|
        expect(record).to have_key('id')
        expect(record).to have_key('clock_in_at')
        expect(record).to have_key('clock_out_at')
        expect(record).to have_key('duration_in_hours')
        expect(record).to have_key('completed')
        expect(record).to have_key('created_at')
        expect(record).to have_key('updated_at')
        expect(record).to have_key('user')
      end
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
