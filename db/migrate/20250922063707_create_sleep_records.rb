class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid # The t.references :user automatically creates an index on user_id
      t.datetime :clock_in_at, null: false
      t.datetime :clock_out_at

      t.timestamps
    end

    add_index :sleep_records, :clock_in_at
    add_index :sleep_records, :clock_out_at
  end
end
