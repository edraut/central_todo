class Notifier < ActionMailer::Base
  include ApplicationHelper
  default :from => "'#{APP_NAME} Notifications' <notifications@#{DOMAIN_NAME}>"
  default_url_options[:host] = DOMAIN_NAME

  def password_reset_instructions(user)  
    @password_reset_url = edit_user_url(:id => user.perishable_token, :reset_password => true)
    @user = user 
    mail( :subject => "Password Reset Instructions",
          :to => user.email )
  end  

  def account_validation_instructions(user)
    @account_validation_url = activate_user_url(:id => user.perishable_token, :validate_account => true)  
    mail( :subject => "Account Validation Link",
          :to => user.email )
  end

  def sms_verification(user)
    @user = user
    @account_url = settings_user_url(:id => user.id)  
    mail( :from => "<notifications@#{DOMAIN_NAME}>",
          :subject => nil,
          :to => user.sms_email )
  end

  def share_plan(plan,email)
    @plan = plan
    mail( :subject => "#{plan.user.email} shared the plan '#{plan.title}' with you",
          :to => email)
  end

  def remind(reminder)  
    @reminder = reminder
    @plan_url = "http://#{DOMAIN_NAME}/#{@reminder.remindable_type.underscore.pluralize}/#{@reminder.remindable_id}"
    mail( :from => "'#{APP_NAME} Reminders' <notifications@#{DOMAIN_NAME}>",
          :subject => "#{reminder.remindable.class.display_name} due -- #{truncate_clean(reminder.remindable.title,{:length => 100, :omission => '...'})}",
          :to => reminder.user.email)
  end  

  def remind_sms(reminder)  
    @reminder = reminder
    mail( :from => "<notifications@#{DOMAIN_NAME}>",
          :subject => nil,
          :to => reminder.user.sms_email)
  end  
end