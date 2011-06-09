class AddTos < ActiveRecord::Migration
  def self.up
    add_column :users, :tos_agreed, :boolean, :default => false
  end

  def self.down
    remove_column :users, :tos_agreed
  end
end