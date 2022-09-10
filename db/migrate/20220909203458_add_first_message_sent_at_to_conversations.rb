class AddFirstMessageSentAtToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :first_message_dispatched_at, :timestamp
    add_index :conversations, [:client_phone_number, :first_message_dispatched_at], name: 'first_msg_dispatch_client_number_idx_context'
    add_index :conversations, [:keywords, :first_message_dispatched_at], name: 'first_msg_dispatch_keywords_idx_content'
  end
end
