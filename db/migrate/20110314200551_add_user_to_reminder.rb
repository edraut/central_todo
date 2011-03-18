class AddUserToReminder < ActiveRecord::Migration
  def self.up
    add_column :reminders, :user_id, :integer
    add_column :reminders, :state, :string
  end

  def self.down
    remove_column :reminders, :state
    remove_column :reminders, :user_id
  end
end