class Task < ActiveRecord::Base
  #constants

  #associations
  belongs_to :user
  belongs_to :project
  belongs_to :situation

  #named_scopes
  scope :unorganized, :conditions => {:project_id => nil, :situation_id => nil}
  scope :projectless, :conditions => {:project_id => nil}
  scope :situationless, :conditions => {:situation_id => nil}
  scope :with_due_date, :conditions => "tasks.due_date is not null"
  scope :without_due_date, :conditions => "tasks.due_date is null"
  scope :overdue, :conditions => ["tasks.due_date < :now",{:now => Time.now}]
  scope :due_today, :conditions => ["tasks.due_date > :now and tasks.due_date < :end_today",{:now => Time.now,:end_today => Date.today.to_time + 1.day}]
  scope :due_7_days, :conditions => ["tasks.due_date > :now and tasks.due_date < :seven_days",{:now => Time.now,:seven_days => Date.today.to_time + 7.day}]
  scope :due_30_days, :conditions => ["tasks.due_date > :now and tasks.due_date < :thirty_days",{:now => Time.now,:thirty_days => Date.today.to_time + 30.day}]
  scope :priority, :conditions => {:priority => true}
  scope :one_off, :conditions => {:project_id => nil}
  scope :cooler, :conditions => "tasks.state = 'cooler'"
  scope :ordered, :order => 'position'
  scope :by_due_date, :order => 'due_date'
  scope :by_create_date, :order => 'created_at desc'
  scope :recent, :order => 'id desc'
  scope :five, :limit => 5
  scope :twenty_five, :limit => 25
  scope :active, :conditions => "tasks.state = 'active'"
  scope :incomplete, :conditions => "tasks.state != 'complete' and tasks.state != 'retired'"
  scope :complete, :conditions => {:state => 'complete'}
  scope :unretired, :conditions => "tasks.state != 'retired' and tasks.state != 'cooler'"
  scope :retired, :conditions => {:state => 'retired'}
  scope :done, :conditions => "(tasks.state = 'complete' or tasks.state = 'retired')"
  #special behaviors
  state_machine :action => nil do
    state :cooler
    state :active
    state :complete
    state :retired
    event :activate do
      transition all => :active
    end
    event :cool do
      transition :active => :cooler
    end
    event :finish do
      transition :active => :complete
    end
    event :retire do
      transition :complete => :retired
    end
  end
  #validations
  validates_presence_of :title

  #callbacks
  before_create :set_position
  before_save :handle_ownership

  #class methods

  #instance methods

  def done?
    self.complete? or self.retired?
  end
  
  def overdue?
    !self.due_date.nil? and self.due_date < Time.now
  end
  
  def set_position
    self.position = self.project_id.nil? ? ((self.user.tasks.projectless.count < 1) ? 0 : self.user.tasks.projectless.maximum(:position) + 1) : ((self.project.tasks.count < 1) ? 0 : self.project.tasks.maximum(:position) + 1)
  end
  
  def handle_ownership
    if self.situation and self.situation.user_id != self.user_id
      self.situation_id = nil
    end
    if self.project and self.project.user_id != self.user_id
      self.project_id = nil
    end
  end
end
