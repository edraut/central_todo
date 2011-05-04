class AddNoFolderOption < ActiveRecord::Migration
  def self.up
    add_column :project_sharers, :no_folder, :boolean, :default => false
  end

  def self.down
    remove_column :project_sharers, :no_folder
  end
end