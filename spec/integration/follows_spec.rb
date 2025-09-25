require 'swagger_helper'

RSpec.describe 'Follows API', type: :request do
  path '/api/v1/follows' do
    get 'Retrieves all follows' do
      tags 'Follows'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'follows found' do
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end

    post 'Creates a follow' do
      tags 'Follows'
      consumes 'application/json'
      parameter name: :follow, in: :body, schema: {
        type: :object,
        properties: {
          follower_id: { type: :string },
          following_id: { type: :string }
        },
        required: [ 'follower_id', 'following_id' ]
      }

      response '201', 'follow created' do
        let(:follower) { User.create(name: 'Follower') }
        let(:following) { User.create(name: 'Following') }
        let(:follow) { { follower_id: follower.id, following_id: following.id } }
        run_test! do |response|
          expect(response.status).to eq(201)
        end
      end

      response '422', 'invalid request' do
        let(:follower) { User.create(name: 'Follower') }
        let(:follow) { { follower_id: follower.id, following_id: follower.id } }
        run_test! do |response|
          expect(response.status).to eq(422)
        end
      end
    end
  end

  path '/api/v1/follows/{id}' do
    get 'Retrieves a follow' do
      tags 'Follows'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'follow found' do
        let(:id) { Follow.create(follower: User.create(name: 'Follower'), following: User.create(name: 'Following')).id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '404', 'follow not found' do
        let(:id) { 'non-existent' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end

    delete 'Deletes a follow' do
      tags 'Follows'
      parameter name: :id, in: :path, type: :string

      response '204', 'follow deleted' do
        let(:id) { Follow.create(follower: User.create(name: 'Follower'), following: User.create(name: 'Following')).id }
        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response '404', 'follow not found' do
        let(:id) { 'non-existent' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end
end