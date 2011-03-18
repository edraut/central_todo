class ChangeSitToLabel < ActiveRecord::Migration
  def self.up
    rename_table :situations, :labels
    rename_table :task_situations, :task_labels
    rename_column :task_labels, :situation_id, :label_id
  end

  def self.down
    rename_column :task_labels, :label_id, :situation_id
    rename_table :task_labels, :task_situations
    rename_table :labels, :situations
  end
end