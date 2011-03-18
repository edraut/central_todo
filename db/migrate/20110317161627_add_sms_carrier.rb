class AddSmsCarrier < ActiveRecord::Migration
  def self.up
    add_column :users, :sms_carrier, :string
    add_column :users, :sms_code, :string
  end

  def self.down
    remove_column :users, :sms_code
    remove_column :users, :sms_carrier
  end
end