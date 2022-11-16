class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.string :client_phone_number, null: false
      t.string :business_phone_number, null: false
      t.timestamp :latest_message_sent_at

      t.timestamps
    end

    add_index :conversations, :latest_message_sent_at
    add_index :conversations, :client_phone_number
    add_index :conversations, %i[client_phone_number business_phone_number], unique: true, name: 'index_conversations_phone_pair_unique'
  end
end
