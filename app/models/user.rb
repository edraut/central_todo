class User < ActiveRecord::Base
  #constants

  #associations
  has_many :tasks, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :situations, :dependent => :destroy
  has_many :task_situations, :through => :situations
  has_many :project_sharers, :dependent => :destroy
  has_many :shared_projects, :through => :project_sharers, :source => :project

  #named_scopes

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
  def validate
    self.errors.add(:email,"That email is already in use, please select another.") if User.find(:first, :conditions => ["lower(email) = :email",{:email => self.email.downcase}])
  end
  #callbacks

  #class methods

  #instance methods

  def prepare_for_validation
    self.reset_perishable_token!
    Notifier.account_validation_instructions(self).deliver
  end

  def prepare_password_reset
    self.reset_perishable_token!  
    Notifier.password_reset_instructions(self).deliver
  end  
  
end
