class AddTaskState < ActiveRecord::Migration
  def self.up
    add_column :tasks, :state, :string
    Task.reset_column_information
    Task.update_all("state = 'retired'","retired = 't'")
    Task.update_all("state = 'complete'","complete = 't'")
    remove_column :tasks, :retired
    remove_column :tasks, :complete
  end

  def self.down
    add_column :tasks, :complete, :boolean,    :default => false
    add_column :tasks, :retired, :boolean,     :default => false
    Task.reset_column_information
    Task.update_all("retired = 't'","state = 'retired'")
    Task.update_all("complete = 't'","state = 'complete'")
    remove_column :tasks, :state
  end
end
