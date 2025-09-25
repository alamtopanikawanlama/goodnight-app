require 'swagger_helper'

RSpec.describe 'SleepRecords API', type: :request do
  path '/api/v1/users/{user_id}/sleep_records' do
    get 'Retrieves all sleep records for a user' do
      tags 'SleepRecords'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false

      response '200', 'sleep records found' do
        let(:user_id) { User.create(name: 'Test User').id }
        let(:start_date) { 2.days.ago.to_date.to_s }
        let(:end_date) { Date.today.to_s }
        before do
          SleepRecord.create(user_id: user_id, clock_in_at: 2.days.ago)
          SleepRecord.create(user_id: user_id, clock_in_at: 1.day.ago)
          SleepRecord.create(user_id: user_id, clock_in_at: Date.today)
        end
        run_test! do |response|
          expect(response.status).to eq(200)
          data = JSON.parse(response.body)
          expect(data).to have_key('sleep_records')
          expect(data).to have_key('pagination')
        end
      end

      response '404', 'user not found' do
        let(:user_id) { 'non-existent' }
        run_test! do |response|
          expect(response.status).to eq(404)
        end 
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/{id}' do
    get 'Retrieves a sleep record' do
      tags 'SleepRecords'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '200', 'sleep record found' do
        let(:user_id) { User.create(name: 'Test User').id }
        let(:id) { SleepRecord.create(user_id: user_id, clock_out_at: Time.now).id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '404', 'sleep record not found' do
        let(:user_id) { User.create(name: 'Test User').id }
        let(:id) { 'non-existent' }

        before do
          failure_result = ServiceResult.new(
            data: nil,
            errors: [],
            message: "Couldn't find SleepRecord with 'id'=\"non-existent\" [WHERE \"sleep_records\".\"user_id\" = $1]",
            meta: nil,
            success: false
          )
          allow(SleepRecordService).to receive(:destroy).with(user_id, id).and_return(failure_result)
        end

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/{id}' do
    delete 'Deletes a sleep record' do
      tags 'SleepRecords'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string

      response '204', 'sleep record deleted' do
        let(:user_id) { 'xxx'}
        let(:id) { 'xxx' }

        before do
          allow(SleepRecordService).to receive(:destroy).with(user_id, id).and_return(
            ServiceResult.new(success: true, message: 'Sleep record deleted successfully')
          )
        end

        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end

      response '404', 'sleep record not found' do
        let(:user_id) { User.create(name: 'Test User').id }
        let(:id) { 'non-existent' }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/clock_in' do
    post 'Clock in for sleep' do
      tags 'SleepRecords'
      parameter name: :user_id, in: :path, type: :string

      response '201', 'clocked in' do
        let(:user_id) { User.create(name: 'Test User').id }
        run_test! do |response|
          expect(response.status).to eq(201)
        end
      end

      response '400', 'already clocked in' do
        let(:user_id) { User.create(name: 'Test User').id }
        before do
          SleepRecordService.clock_in(user_id)
        end
        run_test! do |response|
          expect(response.status).to eq(400)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/clock_out' do
    post 'Clock out for sleep' do
      tags 'SleepRecords'
      parameter name: :user_id, in: :path, type: :string

      before do
        user = User.create(name: 'Test User')
        SleepRecordService.clock_in(user.id)
      end

      response '200', 'clocked out' do
        let(:user_id) { User.last.id }
        let(:sleep_record) { SleepRecord.find_by(user_id: user_id) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(sleep_record.id)
          expect(data['completed']).to be true
          expect(data['clock_out_at']).not_to be_nil
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/current' do
    get 'Retrieves current sleep record' do
      tags 'SleepRecords'
      parameter name: :user_id, in: :path, type: :string

      response '200', 'current sleep record found' do
        let(:user_id) { User.create(name: 'Test User').id }

        before do
          SleepRecordService.clock_in(user_id)
        end

        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end

      response '404', 'no current sleep record' do
        let(:user_id) { User.create(name: 'Test User').id }
        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/users/{user_id}/sleep_records/friends' do
    get 'Retrieves friends sleep records' do
      tags 'SleepRecords'
      parameter name: :user_id, in: :path, type: :string
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false

      response '200', 'friends sleep records found' do
        let(:user_id) { User.create(name: 'Test User').id }
        let(:friend) { User.create(name: 'Friend User') }
        let(:start_date) { 2.days.ago.to_date.to_s }
        let(:end_date) { Date.today.to_s }
        before do
          Follow.create(follower_id: user_id, following_id: friend.id)
          SleepRecord.create(user_id: friend.id, clock_in_at: 2.days.ago)
          SleepRecord.create(user_id: friend.id, clock_in_at: Date.today)
        end
        run_test! do |response|
          expect(response.status).to eq(200)
          data = JSON.parse(response.body)
          expect(data).to have_key('friends_sleep_records')
          expect(data).to have_key('pagination')
        end
      end
    end
  end
end