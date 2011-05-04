class User < ActiveRecord::Base
  #constants

  #associations
  has_many :tasks, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :folders, :dependent => :destroy
  has_many :labels, :dependent => :destroy
  has_many :task_labels, :through => :labels
  has_many :project_sharers, :dependent => :destroy
  has_many :shared_projects, :through => :project_sharers, :source => :project
  has_many :reminders

  #named_scopes

  scope :sharing_parents_for, lambda {|user| 
    select("distinct users.id,users.email,users.name").
    joins("inner join projects pr1 on pr1.user_id = users.id inner join project_sharers on project_sharers.project_id = pr1.id").
    where("project_sharers.user_id = #{user.id}")
  }
  scope :sharing_children_for, lambda {|user| 
    select("distinct users.id,users.email,users.name").
    joins("inner join project_sharers ps1 on ps1.user_id = users.id inner join projects pr1 on pr1.id = ps1.project_id").
    where("pr1.user_id = #{user.id}")
  }
  #special behaviors
  acts_as_authentic

  state_machine :state, :initial => :active do
    event :validate_account do
      transition :not_valid => :active
    end
    event :deactivate do
      transition :active => :inactive
    end
    state :not_valid
    state :active
    state :inactive
  end
    
  #validations

  #callbacks
  before_save :handle_sms
  
  #class methods
  def self.generate_code(size = 5)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end
  
  def self.contacts_for(user)
    self.find_by_sql("
      SELECT distinct users.id,users.email,users.name from users inner join projects pr1 on pr1.user_id = users.id inner join project_sharers on project_sharers.project_id = pr1.id
      WHERE project_sharers.user_id = #{user.id}
      UNION
      SELECT distinct users.id,users.email,users.name from users inner join project_sharers ps1 on ps1.user_id = users.id inner join projects pr1 on pr1.id = ps1.project_id
      WHERE pr1.user_id = #{user.id}
      ")
  end
  #instance methods

  def handle
    self.name.blank? ? self.email : self.name
  end
  
  def sharing_parents
    User.sharing_parents_for(self)
  end
  
  def sharing_parent_ids
    User.sharing_parent_ids_for(self)
  end
  
  def sharing_children
    User.sharing_children_for(self)
  end
  
  def sharing_children_ids
    User.sharing_children_ids_for(self)
  end
  
  def contacts
    User.contacts_for(self)
  end
  
  def comments
    Comment.joins("left outer join projects p on p.id = comments.commentable_id and comments.commentable_type = 'Project' left outer join project_sharers pps on pps.project_id = p.id left outer join tasks t on t.id = comments.commentable_id and comments.commentable_type = 'Task' left outer join projects tp on tp.id = t.project_id left outer join project_sharers tpps on tp.id = tpps.project_id").
      where("(comments.commentable_type = 'Project' and (p.user_id = #{self.id} or pps.user_id = #{self.id})) or (comments.commentable_type = 'Task' and (t.user_id = #{self.id} or tp.user_id = #{self.id} or tpps.user_id = #{self.id}))")
  end
  
  def available_reminder_types
    if self.sms_valid?
      [['email','EmailReminder'],['SMS','SmsReminder']]
    else
      [['email','EmailReminder']]
    end
  end
  
  def sms_email
    sms_number + SmsReminder::SMS_GATEWAYS[sms_carrier]
  end
  
  def clean_phone_number(number)
    number.gsub(/[-\(\)\.]/,'')[-10..-1]
  end
  
  def clean_sms_number
    self.sms_number = clean_phone_number(self.sms_number)
  end
  
  def handle_sms
    if self.sms_number_changed? and !self.sms_number.blank?
      self.clean_sms_number
      self.sms_code = self.class.generate_code
    end
  end
  
  def send_sms_verification
    Notifier.sms_verification(self).deliver
  end
  
  def least_used_color
    self.labels.select("labels.color, count(labels.color) as color_count").group("labels.color").order("color_count").limit(1)
  end
  
  def prepare_for_validation
    self.reset_perishable_token!
    Notifier.account_validation_instructions(self).deliver
  end

  def prepare_password_reset
    self.reset_perishable_token!  
    Notifier.password_reset_instructions(self).deliver
  end  
  
end
