class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :conversation, foreign_key: true
      t.string :body, null: false
      t.jsonb :meta, null: false
      t.boolean :outgoing, null: false
      t.timestamp :sent_at
      t.boolean :read, null: false, default: false

      t.timestamps
    end

    add_index :messages, :meta
  end
end
