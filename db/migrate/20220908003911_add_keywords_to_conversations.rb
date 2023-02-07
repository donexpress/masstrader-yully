class AddKeywordsToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :keywords, :string, array:true, default: []
    add_index :conversations, :keywords
  end
end
