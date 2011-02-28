class AddTaskState < ActiveRecord::Migration
  def self.up
    add_column :tasks, :state, :string
    Task.reset_column_information
    Task.update_all("state = 'archived'","archived = 't'")
    Task.update_all("state = 'complete'","complete = 't'")
    remove_column :tasks, :archived
    remove_column :tasks, :complete
  end

  def self.down
    add_column :tasks, :complete, :boolean,    :default => false
    add_column :tasks, :archived, :boolean,     :default => false
    Task.reset_column_information
    Task.update_all("archived = 't'","state = 'archived'")
    Task.update_all("complete = 't'","state = 'complete'")
    remove_column :tasks, :state
  end
end
