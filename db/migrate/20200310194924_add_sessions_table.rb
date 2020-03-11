class AddSessionsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions, id: false do |t|
      t.string :uuid, limit: 36, primary_key: true, null: false
      t.string :user_uuid
      t.string :ip_address
      t.text :user_agent
      t.timestamps
    end

    add_index :sessions, :user_uuid
    add_index :sessions, :updated_at
  end
end
