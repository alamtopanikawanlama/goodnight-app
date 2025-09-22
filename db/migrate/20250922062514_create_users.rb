class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name

      t.timestamps
    end

    add_index :users, :name, unique: true
  end
end
