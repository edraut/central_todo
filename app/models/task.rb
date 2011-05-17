class Task < ActiveRecord::Base
  include Remindable
  #constants

  #associations
  belongs_to :user
  belongs_to :project
  has_many :task_labels, :dependent => :destroy
  has_many :labels, :through => :task_labels
  has_many :reminders, :as => :remindable, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  #named_scopes
  scope :unorganized, where( {:project_id => nil} )
  scope :with_due_date, where( "tasks.due_date is not null" )
  scope :without_due_date, where( "tasks.due_date is null" )
  scope :overdue, lambda{ where(["tasks.due_date < :now",{:now => Time.now}]) }
  scope :priority, where( {:priority => true} )
  scope :one_off, where( {:project_id => nil} )
  scope :ordered, order( 'position')
  scope :by_due_date, order('due_date')
  scope :by_create_date, order('created_at desc')
  scope :recent, order('id desc')
  scope :two, limit(2)
  scope :three, limit(3)
  scope :five, limit(5)
  scope :twenty_five, limit(25)
  scope :only_once, select("distinct tasks.id,tasks.title,tasks.project_id,tasks.user_id,tasks.due_date,tasks.description,tasks.position,tasks.priority,tasks.state")
  scope :active, where( "tasks.state = 'active'")
  scope :complete, where( {:state => 'complete'} )
  scope :unarchived, where( "tasks.state != 'archived' and tasks.state != 'cooler'" )
  scope :archived, where( {:state => 'archived'} )
  scope :done, where( "(tasks.state = 'complete' or tasks.state = 'archived')" )
  scope :for_user, lambda { |user| joins("left outer join project_sharers on project_sharers.project_id = tasks.project_id inner join projects on projects.id = tasks.project_id").
                                    where( "(project_sharers.user_id = #{user.id} or tasks.user_id = #{user.id} or projects.user_id = #{user.id})" )}
  scope :for_label, lambda { |label|  joins("inner join task_labels on task_labels.task_id = tasks.id").
                                      where("task_labels.label_id = #{label.id}")}
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
  
  def shared?
    self.sharers.count > 0
  end

  def sharers
    User.joins(:project_sharers).where(["project_sharers.project_id = :project_id",{:project_id => self.project_id}])
  end

  def available_labels
    if self.project
      self.project.user.labels
    else
      self.user.labels
    end
  end
  
  def done?
    self.complete? or self.archived?
  end
  
  def overdue?
    Task.overdue?(self.due_date)
  end
  
  def set_position
    self.position = self.project_id.nil? ? ((self.user.tasks.unorganized.count < 1) ? 0 : self.user.tasks.unorganized.maximum(:position) + 1) : ((self.project.tasks.count < 1) ? 0 : self.project.tasks.maximum(:position) + 1)
  end
  
  def handle_attributes(new_attributes,attribute = nil,nullify = false)
    if nullify
      new_attributes[attribute] = nil
    end
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

  def all_users
    self.project.all_users
  end
  
  def handle_ownership
    if self.project and self.project.user_id != self.user_id and !self.project.sharers.map{|s| s.id}.include? self.user_id
      self.project_id = nil
    end
  end
  
  def self.overdue?(date)
    !date.nil? and date < Date.today
  end
end
