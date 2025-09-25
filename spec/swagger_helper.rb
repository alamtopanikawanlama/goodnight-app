# filepath: spec/swagger_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.to_s + '/swagger'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      components: {
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :string },
              name: { type: :string },
              followers_count: { type: :integer },
              following_count: { type: :integer },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time }
            },
            required: [ 'id', 'name' ]
          },
          follow: {
            type: :object,
            properties: {
              id: { type: :string },
              follower: { '$ref' => '#/components/schemas/user' },
              following: { '$ref' => '#/components/schemas/user' },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time }
            },
            required: [ 'id', 'follower', 'following' ]
          },
          sleep_record: {
            type: :object,
            properties: {
              id: { type: :string },
              clock_in_at: { type: :string, format: :date_time },
              clock_out_at: { type: :string, format: :date_time, nullable: true },
              duration_in_hours: { type: :number, format: :float },
              completed: { type: :boolean },
              created_at: { type: :string, format: :date_time },
              updated_at: { type: :string, format: :date_time },
              user: { '$ref' => '#/components/schemas/user' }
            },
            required: [ 'id', 'clock_in_at', 'created_at', 'updated_at', 'user' ]
          }
        }
      }
    }
  }
end