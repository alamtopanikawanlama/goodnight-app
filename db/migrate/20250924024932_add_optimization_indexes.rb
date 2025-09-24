class AddOptimizationIndexes < ActiveRecord::Migration[8.0]
  def change
    # Index for sleep_records - optimize queries by user and status
    add_index :sleep_records, [:user_id, :clock_out_at], 
              name: 'index_sleep_records_on_user_id_and_clock_out_at'
    
    # Index for sleep_records - optimize for ongoing records (clock_out_at is null)
    add_index :sleep_records, [:user_id, :clock_in_at], 
              where: 'clock_out_at IS NULL',
              name: 'index_sleep_records_ongoing_by_user'
    
    # Index for sleep_records - optimize for completed records with ordering
    add_index :sleep_records, [:user_id, :created_at], 
              where: 'clock_out_at IS NOT NULL',
              name: 'index_sleep_records_completed_by_user_date'
    
    # Index for sleep_records - optimize queries by created_at date
    add_index :sleep_records, [:created_at, :user_id],
              name: 'index_sleep_records_on_created_at_and_user_id'
    
    # Index for follows - optimize counting followers
    add_index :follows, :following_id, 
              name: 'index_follows_on_following_id_for_count'
    
    # Index for follows - optimize counting following
    add_index :follows, :follower_id, 
              name: 'index_follows_on_follower_id_for_count'
    
    # Composite index for users with created_at for pagination
    add_index :users, [:created_at, :id],
              name: 'index_users_on_created_at_and_id'
    
    # Index for sleep_records with duration calculation optimization
    add_index :sleep_records, [:clock_in_at, :clock_out_at],
              where: 'clock_out_at IS NOT NULL',
              name: 'index_sleep_records_for_duration_calc'
  end
end
