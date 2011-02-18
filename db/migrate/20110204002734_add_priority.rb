class AddPriority < ActiveRecord::Migration
  def self.up
    add_column :tasks, :priority, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tasks, :priority
  end
end