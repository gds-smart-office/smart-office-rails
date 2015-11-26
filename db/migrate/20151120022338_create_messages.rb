class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id     
      t.string  :user_name
      t.string  :chat_id     
      t.string  :chat_title
      t.string  :action

      t.timestamps null: false
    end
  end
end
