class Notifier < ActionMailer::Base
  default :from => "'Ahead of the Game Notifications' <notifications@ahead-of-the-ga.me>"
  default_url_options[:host] = "ahead-of-the-ga.me"  

  def password_reset_instructions(user)  
    @password_reset_url = edit_user_url(:id => user.perishable_token, :reset_password => true)  
    mail( :subject => "Password Reset Instructions",
          :recipients => user.email )
  end  

  def account_validation_instructions(user)
    @account_validation_url = activate_user_url(:id => user.perishable_token, :validate_account => true)  
    mail( :subject => "Account Validation Link",
          :recipients => user.email )
  end
end