class Project < ActiveRecord::Base
  #constants

  #associations
  belongs_to :user
  has_many :tasks, :dependent => :destroy

  #named_scopes
  scope :with_due_date, :conditions => "projects.due_date is not null"
  scope :without_due_date, :conditions => "projects.due_date is null"
  scope :active, :conditions => "projects.state = 'active'"
  scope :complete, :conditions => {:state => 'complete'}
  scope :unarchived, :conditions => "projects.state != 'archived'"
  scope :archived, :conditions => {:state => 'archived'}
  scope :five, :limit => 5
  scope :twenty_five, :limit => 25
  scope :ordered, :order => 'projects.position'
  scope :by_due_date, :order => 'due_date'
  scope :by_create_date, :order => 'created_at desc'
  #special behaviors

  state_machine :initial => :active, :action => nil do
    after_transition :on => :archive, :do => :handle_task_state
    after_transition :on => :finish, :do => :handle_task_state
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

  #callbacks

  #class methods
  def self.display_name
    'Plan'
  end

  #instance methods
  def done?
    self.complete? or self.archived?
  end
  
  def overdue?
    !self.due_date.nil? and self.due_date < Time.now
  end
  
  def all_complete
    (self.tasks.count == self.tasks.done.count) && (self.tasks.count > 0)
  end
  
  def handle_attributes(new_attributes)
    new_state = new_attributes.delete(:state)
    self.attributes = (new_attributes)
    if new_state == self.state
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
      return true
    end
    
  end
  
  def handle_task_state
    self.tasks.each do |task|
      task.archive
      task.save
    end
  end
end
