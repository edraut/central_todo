class TaskLabel < ActiveRecord::Base
  belongs_to :task
  belongs_to :label
  
  scope :for_task, lambda{ |task| {:conditions => {:task_id => task.id}}}
end