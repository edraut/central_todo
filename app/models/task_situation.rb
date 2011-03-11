class TaskSituation < ActiveRecord::Base
  belongs_to :task
  belongs_to :situation
  
  scope :for_task, lambda{ |task| {:conditions => {:task_id => task.id}}}
end