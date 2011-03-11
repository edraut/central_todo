class TaskSituation < ActiveRecord::Migration
  class TaskSituation < ActiveRecord::Base
  end
  def self.up
    create_table :task_situations, :force => true do |t|
      t.integer :task_id
      t.integer :situation_id
      t.timestamps
    end
    Task.all.each do |task|
      if task.situation_id
        TaskSituation.create(:task_id => task.id,:situation_id => task.situation_id)
      else
        TaskSituation.create :task_id => task.id
      end
    end
    remove_column :tasks, :situation_id
  end

  def self.down
    add_column :tasks, :situation_id, :integer
    Task.reset_column_information
    TaskSituation.all.each do |ts|
      task = ts.task
      task.situation_id = ts.situation_id
      task.save
    end
    drop_table :task_situations
  end
end
