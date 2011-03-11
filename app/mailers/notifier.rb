class Notifier < ActionMailer::Base
  default :from => "'My Time Notifications' <notifications@#{DOMAIN_NAME}>"
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

  def share_plan(plan,email)
    @plan = plan
    mail( :subject => "#{plan.user.email} shared the plan '#{plan.title}' with you",
          :to => email)
  end
end