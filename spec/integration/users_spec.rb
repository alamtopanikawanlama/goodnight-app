# filepath: spec/integration/users_spec.rb
require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'Retrieves all users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'users found' do
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: [ 'name' ]
      }

      response '201', 'user created' do
        let(:user) { { name: 'Test User' } }
        run_test! do |response|
          expect(response.status).to eq(201)
        end
      end

      response '422', 'invalid request' do
        let(:user) { { name: '' } }
        run_test! do |response|
          expect(response.status).to eq(422)
        end
      end
    end
  end

  path '/api/v1/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'user found' do
        let(:id) { User.create(name: 'Test User').id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end

    patch 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response '200', 'user updated' do
        let(:id) { User.create(name: 'Old Name').id }
        let(:user) { { name: 'New Name' } }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '422', 'invalid request' do
        let(:id) { User.create(name: 'Old Name').id }
        let(:user) { { name: '' } }
        run_test! do |response|
          expect(response.status).to eq(422)
        end
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response '200', 'user updated' do
        let(:id) { User.create(name: 'Old Name').id }
        let(:user) { { name: 'Updated Name' } }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '422', 'invalid request' do
        let(:id) { User.create(name: 'Old Name').id }
        let(:user) { { name: '' } }
        run_test! do |response|
          expect(response.status).to eq(422)
        end
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      parameter name: :id, in: :path, type: :string

      response '204', 'user deleted' do
        let(:id) { User.create(name: 'Test User').id }
        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response '404', 'user not found' do
        let(:id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/users/{id}/follow' do
    post 'Follow a user' do
      tags 'Users'
      parameter name: :id, in: :path, type: :string
      parameter name: :target_user_id, in: :query, type: :string

      response '200', 'followed user' do
        let(:id) { User.create(name: 'Follower').id }
        let(:target_user_id) { User.create(name: 'Target').id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '400', 'user invalid' do
        let(:id) { 'invalid-id' }
        let(:target_user_id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(400)
        end
      end
    end
  end

  path '/api/v1/users/{id}/unfollow' do
    delete 'Unfollow a user' do
      tags 'Users'
      parameter name: :id, in: :path, type: :string
      parameter name: :target_user_id, in: :query, type: :string

      response '204', 'unfollowed user' do
        let(:id) { User.create(name: 'Follower').id }
        let(:target_user_id) { User.create(name: 'Target').id }
        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response '400', 'user invalid' do
        let(:id) { 'invalid-id' }
        let(:target_user_id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(400)
        end
      end
    end
  end

  path '/api/v1/users/{id}/followers' do
    get 'Retrieves user followers' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'followers found' do
        let(:id) { User.create(name: 'Test User').id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '404', 'user not found' do
        let(:id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/users/{id}/following' do
    get 'Retrieves users being followed' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'following found' do
        let(:id) { User.create(name: 'Test User').id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
      
      response '404', 'user not found' do
        let(:id) { 'invalid-id' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end
end