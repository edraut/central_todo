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
  scope :ordered, :order => 'position'
  scope :by_due_date, :order => 'due_date'
  scope :by_create_date, :order => 'created_at desc'
  scope :recent, :order => 'id desc'
  scope :five, :limit => 5
  scope :twenty_five, :limit => 25
  scope :active, :conditions => "tasks.state = 'active'"
  scope :complete, :conditions => {:state => 'complete'}
  scope :unarchived, :conditions => "tasks.state != 'archived' and tasks.state != 'cooler'"
  scope :archived, :conditions => {:state => 'archived'}
  scope :done, :conditions => "(tasks.state = 'complete' or tasks.state = 'archived')"
  #special behaviors
  state_machine :initial => :active, :action => nil do
    state :active
    state :complete
    state :archived
    event :activate do
      transition all => :active
    end
    event :finish do
      transition :active => :complete
    end
    event :archive do
      transition :complete => :archived
    end
  end
  #validations
  validates_presence_of :title

  #callbacks
  before_create :set_position
  before_save :handle_ownership

  #class methods
  def self.display_name
    'Task'
  end

  #instance methods

  def done?
    self.complete? or self.archived?
  end
  
  def overdue?
    Task.overdue?(self.due_date)
  end
  
  def set_position
    self.position = self.project_id.nil? ? ((self.user.tasks.projectless.count < 1) ? 0 : self.user.tasks.projectless.maximum(:position) + 1) : ((self.project.tasks.count < 1) ? 0 : self.project.tasks.maximum(:position) + 1)
  end
  
  def handle_attributes(new_attributes)
    old_state = self.state
    new_state = new_attributes.delete(:state)
    if new_attributes.has_key? :'due_date(1i)' and !new_attributes.has_key? :'due_date(4i)'
      new_attributes[:'due_date(4i)'] = '12'
    end
    self.attributes = new_attributes
    if new_state.nil? or new_state == self.state
      return false
    else
      case new_state
      when 'archived'
        self.archive
      when 'complete'
        self.finish
      when 'active'
        self.activate
      end
      return old_state
    end
  end

  def handle_ownership
    if self.situation and self.situation.user_id != self.user_id
      self.situation_id = nil
    end
    if self.project and self.project.user_id != self.user_id
      self.project_id = nil
    end
  end
  
  def self.overdue?(date)
    !date.nil? and date < Time.now
  end
end
