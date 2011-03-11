class Project < ActiveRecord::Base
  #constants

  #associations
  belongs_to :user
  has_many :tasks, :dependent => :destroy
  has_many :project_sharers, :dependent => :destroy
  has_many :sharers, :through => :project_sharers, :source => :user
  has_many :project_emails, :dependent => :destroy
  has_many :comments, :as => :commentable
  
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
  scope :for_user, lambda { |user| joins("left outer join project_sharers on project_sharers.project_id = projects.id").
                                    where( "(project_sharers.user_id = #{user.id} or projects.user_id = #{user.id})" )}
  #special behaviors

  state_machine :initial => :active, :action => nil do
    state :active
    state :archived
    event :activate do
      transition all => :active
    end
    event :archive do
      transition :active => :archived
    end
  end
  #validations
  validates_presence_of :title

  #callbacks

  #class methods
  def self.display_name
    'Plan'
  end

  #instance methods
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
  
  def shared?
    self.project_sharers.count > 0
  end
end
