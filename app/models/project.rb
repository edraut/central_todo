class Project < ActiveRecord::Base
  include Remindable
  #constants

  #associations
  belongs_to :user
  belongs_to :folder
  has_many :tasks, :dependent => :destroy
  has_many :project_sharers, :dependent => :destroy
  has_many :sharers, :through => :project_sharers, :source => :user
  has_many :project_emails, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :reminders, :as => :remindable, :dependent => :destroy
  
  #named_scopes
  scope :with_due_date, where("projects.due_date is not null")
  scope :without_due_date, where("projects.due_date is null")
  scope :active, where("projects.state = 'active'")
  scope :incomplete,  select("distinct projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at").
                      joins("left outer join tasks on tasks.project_id = projects.id").
                      where("projects.state = 'active' and (tasks.state = 'active' or tasks.id is null)")
  scope :complete,  select("distinct projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at").
                    joins("left outer join tasks on tasks.project_id = projects.id").
                    where("projects.state = 'active'").
                    group("projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at").
                    having("every(tasks.state != 'active')")
  scope :unarchived, where("projects.state != 'archived'")
  scope :archived, where(:state => 'archived')
  scope :five, limit(5)
  scope :twenty_five, limit(25)
  scope :ordered, order('projects.position')
  scope :by_due_date, order('projects.due_date')
  scope :by_create_date, order('projects.created_at desc')
  scope :shared,  select("distinct projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at").
                  joins(:project_sharers)
  scope :shared_order, order('shared_order')
  scope :for_user, lambda { |user|  select("distinct projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at,case when project_sharers.id is null then projects.position else project_sharers.position end as shared_order").
                                    joins("left outer join project_sharers on project_sharers.project_id = projects.id").
                                    where( "(project_sharers.user_id = #{user.id} or projects.user_id = #{user.id})" )}
  scope :for_folder, lambda { |folder|  select("distinct projects.id,projects.title,projects.description,projects.due_date,projects.user_id,projects.state,projects.position,projects.created_at,case when project_sharers.id is null then projects.position else project_sharers.position end as shared_order").
                                    joins("left outer join project_sharers on project_sharers.project_id = projects.id and project_sharers.user_id = #{folder.user_id}").
                                    where( "(project_sharers.folder_id = #{folder.id} or projects.folder_id = #{folder.id})" )}
  #special behaviors

  state_machine :initial => :active, :action => nil do
    after_transition :on => :archive, :do => :archive_tasks
    after_transition :on => :activate, :do => :unarchive_tasks
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
  before_save :handle_reminders

  #class methods
  def self.display_name
    'Plan'
  end

  #instance methods
  def all_complete?
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
  
  def archive_tasks
    self.tasks.update_all "state = 'archived'"
  end

  def unarchive_tasks
    self.tasks.update_all "state = 'active'"
  end
  
  def folder_for(user)
    if self.user_id == user.id
      self.folder
    else
      self.project_sharers.where(:user_id => user.id).first.folder
    end
  end
  
  def sharers
    User.joins(:project_sharers).where(["project_sharers.project_id = :project_id",{:project_id => self.id}])
  end
  
  def all_users
    self.sharers + [self.user]
  end
  
  def shared?
    self.project_sharers.count > 0
  end
  
  # Needs to be pulled out into a mixin shared amond remindables
end
