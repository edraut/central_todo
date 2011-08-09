class AddStateToFolder < ActiveRecord::Migration
  def self.up
    add_column :folders, :state, :string, :null => false, :default => 'active'
  end

  def self.down
    remove_column :folders, :state
  end
end