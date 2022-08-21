class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :receiver_phone_number
      t.string :message
      t.string :sender_phone_number
      t.jsonb :meta
      t.boolean :outgoing

      t.timestamps
    end

    add_index :messages, :receiver_phone_number
    add_index :messages, :meta
  end
end
