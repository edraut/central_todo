class User < ActiveRecord::Base
  #constants

  #associations
  has_many :tasks, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :situations, :dependent => :destroy


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
  validates_uniqueness_of :email
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
