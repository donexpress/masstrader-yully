class AddLastOutgoingToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :latest_outgoing_sent_at, :timestamp
    add_index :conversations, :latest_outgoing_sent_at
  end
end
