module Remindable
  def handle_reminders
    if self.due_date_changed? and self.due_date.nil?
      self.reminders.destroy_all
    end
  end
  
  def overdue?
    !self.all_complete and self.due_date_past?
  end
    
  def due_date_past?
    !self.due_date.nil? and self.due_date < Time.now
  end

end