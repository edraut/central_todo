class AddSms < ActiveRecord::Migration
  def self.up
    add_column :users, :sms_number, :string
    add_column :users, :sms_valid, :boolean
  end

  def self.down
    remove_column :users, :sms_valid
    remove_column :users, :sms_number
  end
end