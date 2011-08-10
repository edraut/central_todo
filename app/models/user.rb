class User < ActiveRecord::Base
  #constants
  
  attr_accessor :card_hash, :no_tos

  #associations
  has_many :tasks, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :folders, :dependent => :destroy
  has_many :labels, :dependent => :destroy
  has_many :task_labels, :through => :labels
  has_many :project_sharers, :dependent => :destroy
  has_many :shared_projects, :through => :project_sharers, :source => :project
  has_many :reminders, :dependent => :destroy
  has_many :comments
  has_many :plan_templates, :dependent => :destroy
  belongs_to :rate

  #named_scopes

  scope :sharing_parents_for, lambda {|user| 
    select("distinct users.id,users.email,users.name").
    joins("inner join projects pr1 on pr1.user_id = users.id inner join project_sharers on project_sharers.project_id = pr1.id").
    where("project_sharers.user_id = #{user.id}").
    order("users.id")
  }
  scope :sharing_children_for, lambda {|user| 
    select("distinct users.id,users.email,users.name").
    joins("inner join project_sharers ps1 on ps1.user_id = users.id inner join projects pr1 on pr1.id = ps1.project_id").
    where("pr1.user_id = #{user.id}").
    order("users.id")
  }
  scope :free_trial_ending, where("(date(created_at) + interval '26 days') = current_date")
  scope :free_trial_over, where("(date(created_at) + interval '31 days') = current_date")
  scope :recent, order('id desc')
  #special behaviors
  acts_as_authentic do |c|
    c.logged_in_timeout = 2.weeks
  end
  
  state_machine :state, :initial => :in_good_standing, :action => nil do
    event :hold_account do
      transition any => :can_log_in
    end
    event :activate_account do
      transition any => :in_good_standing
    end
    state :can_log_in
    state :in_good_standing
  end
    
  #validations
  validates_with UserValidator
  #callbacks
  before_create :set_initial_billing_date
  before_save :handle_sms
  before_save :handle_validity

  # after_create :handle_first_credit_card_attempt
  
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
  
  def shared_comments
    Comment.select("distinct comments.id, comments.user_id, comments.commentable_id, comments.commentable_type, comments.body, comments.created_at, comments.updated_at").
      joins("left outer join projects p on p.id = comments.commentable_id and comments.commentable_type = 'Project' left outer join project_sharers pps on pps.project_id = p.id left outer join tasks t on t.id = comments.commentable_id and comments.commentable_type = 'Task' left outer join projects tp on tp.id = t.project_id left outer join project_sharers tpps on tp.id = tpps.project_id").
      where("(comments.commentable_type = 'Project' and (p.user_id = #{self.id} or pps.user_id = #{self.id}) and comments.user_id != #{self.id}) or (comments.commentable_type = 'Task' and (t.user_id = #{self.id} or tp.user_id = #{self.id} or tpps.user_id = #{self.id}) and comments.user_id != #{self.id})")
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

  def handle_first_credit_card_attempt
    self.add_credit_card
    return true
  end
  
  def account_level
    case self.class.name
    when 'PaidAccount'
      self.rate_id
    when 'FreeAccount'
      'Collaborator'
    end
  end
  
  def free_trial?
    Date.today <= (self.created_at + 30.days).to_date
  end
  
  def free_trial_end_date
    (self.created_at + 30.days).to_date
  end
  
  def set_initial_billing_date
    self.billing_date = Date.today + 30.days
  end
  ############################################################################################
  ########### Begin CIM methods, copyright 2008 Eric Draut, all rights reserved ##############
  ############################################################################################

  def add_credit_card(card_hash = self.card_hash)
    self.cim_id ||= get_new_cim_id
    if self.cim_id.blank?
      self.errors.add_to_base('It appears there is a problem processing your credit card information. Please contact us at support@getgolist.com.')
      return false
    else
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number => card_hash[:number].gsub(/[\s-]/,''),
        :month => card_hash[:month],
        :year => card_hash[:year],
        :verification_value => card_hash[:cvv],            
        :type => ActiveMerchant::Billing::CreditCard.type?(card_hash[:number])
      )
      gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new( :login => AUTH_NET_LOGIN, :password => AUTH_NET_TRANS_ID )
      response = gateway.create_customer_payment_profile(:customer_profile_id => self.cim_id,:payment_profile => {:payment => {:credit_card => credit_card}, :bill_to => {:zip => card_hash[:zip]}},:validation_mode => :live)
      if response.message != 'Successful.'
        handle_errors(response)
        self.errors.add_to_base("*When attempting to add your card, we got this response from our processor:*<br/> *#{response.message}*<br/> *Please double-check the information you entered, or try using another credit card.*")
        return false
      else
        self.card_valid = true
      end
    end
  end

  def remove_credit_card
    if self.cim_id.blank? or self.cim_payment_profile_id.blank?
      return false
    else
      gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new( :login => AUTH_NET_LOGIN, :password => AUTH_NET_TRANS_ID )
      response = gateway.delete_customer_payment_profile(:customer_profile_id => self.cim_id,:customer_payment_profile_id => self.cim_payment_profile_id)
      if response.message == 'Successful.'
        self.card_valid = false
        self.save
      else
        handle_errors(response)
      end
    end
  end

  def get_new_cim_id
    gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new( :login => AUTH_NET_LOGIN, :password => AUTH_NET_TRANS_ID )
    response = gateway.create_customer_profile(:profile => {:email => self.email})
    if response.message == 'Successful.'
      self.cim_id = response.params['customer_profile_id']
      self.save
    else
      handle_errors(response)
    end
    self.cim_id
  end

  def get_cim_profile
    unless @cim_profile
      refresh_cim_profile
    end
    @cim_profile
  end

  def refresh_cim_profile
    gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new( :login => AUTH_NET_LOGIN, :password => AUTH_NET_TRANS_ID )
    @cim_profile = gateway.get_customer_profile(:customer_profile_id => self.cim_id)
  end

  def cim_payment_profile_id
    if get_cim_profile and get_cim_profile.params.has_key? 'profile' and get_cim_profile.params['profile'].has_key? 'payment_profiles' and get_cim_profile.params['profile']['payment_profiles'].has_key? 'customer_payment_profile_id'
      get_cim_profile.params['profile']['payment_profiles']['customer_payment_profile_id']
    else
      nil
    end
  end

  def card_last_four
    if get_cim_profile and cim_payment_profile_id
      masked_card_number = self.get_cim_profile.params['profile']['payment_profiles']['payment']['credit_card']['card_number']
      return masked_card_number.gsub(/X/,'')
    else
      nil
    end
  end

  def handle_errors(response)
    case response.params['messages']['message']['code']
    when 'E00007'
      self.errors.add_to_base("We could not contact our secure storage facility, please contact customer support.")
      # handle invalid auth.net login/transaction id error here.
    when 'E00039'
      self.cim_id = response.params['messages']['message']['text'].sub(/A duplicate record with id (\d+) already exists./){$1}
      if self.cim_id =~ /^\d+$/
        return self.cim_id
      else
        self.cim_id = nil
        return nil
      end
    else
      Rails.logger.info(response.inspect)
    end
  end

  ###########################################
  ############ End CIM Methods ##############
  ###########################################
  
end

