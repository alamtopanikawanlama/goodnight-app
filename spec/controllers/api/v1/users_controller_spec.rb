require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET #index' do
    let!(:users) { create_list(:user, 3) }

    it 'returns success response' do
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      users_array = json_response['users'] || json_response
      users_array.each do |user_data|
        expect(user_data).to have_key('id')
        expect(user_data).to have_key('name')
        expect(user_data).to have_key('followers_count')
        expect(user_data).to have_key('following_count')
      end
    end

    it 'passes pagination parameters' do
      get :index, params: { page: 1, per_page: 10 }
      
      json_response = JSON.parse(response.body)
      expect(json_response['pagination'].keys).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET #show' do
    context 'when user exists' do
      it 'returns success response' do
        get :show, params: { id: user.id }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['name']).to eq(user.name)
        expect(json_response).to have_key('followers_count')
        expect(json_response).to have_key('following_count')
      end
    end

    context 'when user does not exist' do
      it 'returns not found response' do
        get :show, params: { id: 'non-existent' }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { user: { name: 'Test User' } } }
    let(:invalid_params) { { user: { name: '' } } }

    context 'with valid parameters' do
      it 'creates user successfully' do
        post :create, params: valid_params
        
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        post :create, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) { { id: user.id, user: { name: 'Updated Name' } } }

    context 'with valid parameters' do
      it 'updates user successfully' do
        patch :update, params: valid_params
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Updated Name')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        patch :update, params: { id: user.id, user: { name: '' } }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user exists' do
      it 'deletes user successfully' do
        delete :destroy, params: { id: user.id }
        expect(response).to have_http_status(:no_content) # ubah dari :ok ke :no_content (204)
      end
    end

    context 'when user does not exist' do
      it 'returns not found response' do
        delete :destroy, params: { id: 'non-existent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #follow' do
    it 'follows user successfully' do
      post :follow, params: { id: user.id, target_user_id: other_user.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Successfully followed user')
    end
  end

  describe 'DELETE #unfollow' do
    it 'unfollows user successfully' do
      delete :unfollow, params: { id: user.id, target_user_id: other_user.id }
      expect(response).to have_http_status(:no_content) # ubah dari :ok ke :no_content (204)
    end
  end

  describe 'GET #followers' do
    before do
      user.followers << other_user
    end

    it 'returns user followers with pagination' do
      get :followers, params: { id: user.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('followers')
      expect(json_response['followers'].count).to eq(1)
      expect(json_response).to have_key('pagination')
      expect(json_response['pagination']['current_page']).to eq(1)
      expect(json_response['pagination']['total_count']).to eq(1)
      expect(json_response['pagination']['total_pages']).to eq(1)
      expect(json_response['pagination']['per_page']).to eq(20)
    end
  end

  describe 'GET #following' do
    before do
      user.following << other_user
    end

    it 'returns users being followed with pagination' do
      get :following, params: { id: user.id }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('following')
      expect(json_response['following'].count).to eq(1)
      expect(json_response).to have_key('pagination')
      expect(json_response['pagination']['current_page']).to eq(1)
      expect(json_response['pagination']['total_count']).to eq(1)
      expect(json_response['pagination']['total_pages']).to eq(1)
      expect(json_response['pagination']['per_page']).to eq(20)
    end
  end
end
