class CreateFbEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :fb_events do |t|
      t.jsonb :data, null: false

      t.timestamps
    end
  end
end
