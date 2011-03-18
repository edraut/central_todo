class AddReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders, :force => true do |t|
      t.integer :remindable_id
      t.string  :remindable_type
      t.integer :lead_time
      t.string  :time_units
      t.string  :type
      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end