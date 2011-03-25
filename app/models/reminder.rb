class Reminder < ActiveRecord::Base
  TIME_UNITS = ['minutes','hours','days']
  belongs_to :remindable, :polymorphic => true
  belongs_to :user

  scope :by_time, order('lead_time')
  scope :for_user, lambda { |user| where(:user_id => user.id)}
  scope :next_minute,
    select("distinct(reminders.*)").
    joins("left outer join projects on projects.id = reminders.remindable_id and reminders.remindable_type = 'Project' left outer join tasks on tasks.id = reminders.remindable_id and reminders.remindable_type = 'Task'").
    where(["reminders.state != 'completed' and (projects.due_date - ((reminders.lead_time || reminders.time_units)::interval + interval '1 minute') < now() at time zone 'UTC' and projects.due_date > (now() at time zone 'UTC' - interval '1 minute')) or (tasks.due_date - ((reminders.lead_time || reminders.time_units)::interval + interval '1 minute') < now() at time zone 'UTC' and tasks.due_date > (now() at time zone 'UTC' - interval '1 minute'))",{}])
  
  state_machine :initial => :active, :action => nil do
    state :active
    state :attempted
    state :completed
    event :attempt do
      transition :active => :attempted
    end
    event :complete do
      transition all => :completed
    end
  end
  def time_units_display
    if self.lead_time == 1
      return self.time_units.singularize
    else
      return self.time_units
    end
  end
end