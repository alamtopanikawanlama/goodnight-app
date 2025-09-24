require 'rails_helper'

RSpec.describe Api::V1::FollowsController, type: :controller do
  let(:follow) { create(:follow) }
  let(:follower) { create(:user) }
  let(:following) { create(:user) }

  describe 'GET #index' do
    let!(:follows) { create_list(:follow, 3) }

    it 'returns success response' do
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['follows'].count).to eq(3)
      json_response['follows'].each do |follow_data|
        expect(follow_data).to have_key('id')
        expect(follow_data).to have_key('follower')
        expect(follow_data).to have_key('following')
        expect(follow_data).to have_key('created_at')
        expect(follow_data).to have_key('updated_at')
      end
    end

    it 'passes pagination parameters' do
      get :index, params: { page: 1, per_page: 10 }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('follows')
      expect(json_response).to have_key('pagination')
      expect(json_response['pagination'].keys).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET #show' do
    context 'when follow exists' do
      it 'returns success response' do
        get :show, params: { id: follow.id }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when follow does not exist' do
      it 'returns not found response' do
        get :show, params: { id: 'non-existent' }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        follow: {
          follower_id: follower.id,
          following_id: following.id
        }
      }
    end

    let(:invalid_params) do
      {
        follow: {
          follower_id: follower.id,
          following_id: follower.id
        }
      }
    end

    context 'with valid parameters' do
      it 'creates follow successfully' do
        post :create, params: valid_params
        
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        post :create, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Failed to create follow relationship')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when follow exists' do
      it 'deletes follow successfully' do
        delete :destroy, params: { id: follow.id }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Follow relationship deleted successfully')
      end
    end

    context 'when follow does not exist' do
      it 'returns not found response' do
        delete :destroy, params: { id: 'non-existent' }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
