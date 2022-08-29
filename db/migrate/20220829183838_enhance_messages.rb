class EnhanceMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :delivered_at, :timestamp
    add_column :messages, :dispatched_at, :timestamp
    add_column :messages, :wa_id, :string

    Message.all.each do |message|
      message.update_column(:wa_id, message.meta_wa_id)
    end

    change_column_null :messages, :wa_id, false
    add_index :messages, :wa_id, unique: true
  end
end
