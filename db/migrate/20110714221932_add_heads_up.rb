class AddHeadsUp < ActiveRecord::Migration
  def self.up
    create_table :heads_ups, :force => true do |t|
      t.integer :alertable_id
      t.string :alertable_type
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :heads_ups
  end
end