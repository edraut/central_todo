class AddChargeAttempts < ActiveRecord::Migration
  def self.up
    add_column :users, :charge_attempts, :integer, :null => false, :default => 0
    add_column :users, :charge_failure_reason, :string
  end

  def self.down
    remove_column :users, :charge_failure_reason
    remove_column :users, :charge_attempts
  end
end