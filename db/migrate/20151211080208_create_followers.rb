class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :chat_id
      t.string :chat_title

      t.timestamps null: false
    end
  end
end
