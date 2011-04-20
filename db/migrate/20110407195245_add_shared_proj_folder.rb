class AddSharedProjFolder < ActiveRecord::Migration
  def self.up
    add_column :project_sharers, :folder_id, :integer
  end

  def self.down
    remove_column :project_sharers, :folder_id
  end
end