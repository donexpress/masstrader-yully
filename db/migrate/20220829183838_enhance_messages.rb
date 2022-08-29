class EnhanceMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :wa_id, :string

    Message.where(outgoing: true).each do |message|
      message.update(wa_id: message.meta_wa_id)
    end

    # change_column_null :messages, :wa_id, false
    #
    # add_index :messages, :wa_id, unique: true
  end
end
