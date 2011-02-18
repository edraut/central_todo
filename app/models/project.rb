class Project < ActiveRecord::Base
  #constants

  #associations
  belongs_to :user
  has_many :tasks, :dependent => :destroy

  #named_scopes
  scope :ordered, :order => 'projects.position'
  scope :incomplete, :conditions => "projects.state != 'complete' and projects.state != 'retired'"
  scope :complete, :conditions => {:state => 'complete'}
  scope :unretired, :conditions => "projects.state != 'retired'"
  scope :retired, :conditions => {:state => 'retired'}
  scope :five, :limit => 5
  scope :twenty_five, :limit => 25
  scope :by_due_date, :order => 'due_date'
  scope :by_create_date, :order => 'created_at desc'
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

  #callbacks

  #class methods

  #instance methods
  def all_complete
    self.tasks.count == self.tasks.done.count
  end
end
