class UserSession < Authlogic::Session::Base
   # configuration here, see documentation for sub modules of Authlogic::Session
   generalize_credentials_error_messages "We couldn't find that email/password combination." 
   
end