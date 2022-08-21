class CreateFbEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :fb_events do |t|
      t.jsonb :data

      t.timestamps
    end
  end
end
