class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :following, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end

    add_index :follows, [:follower_id, :following_id], unique: true
  end
end
