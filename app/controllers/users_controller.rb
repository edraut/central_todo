class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :show
  before_filter :handle_broken_browser_methods, :only => [:show, :create]
  
  def new
    @user = User.new
    @page_heading = "Create your toDo account"
  end
  
  def create
    @user = User.new(params[:user].merge(:time_zone => Time.zone))
    if @user.save
      @user_session = UserSession.new(:email => @user.email, :password => params[:user][:password])
      @user_session.save
      redirect_back_or_default dashboard_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = @this_user
    handle_attribute_partials('show')
  end

  def edit
    if params[:reset_password]
      load_user_using_perishable_token
      render :template => 'users/reset_password' and return
    else
      require_user
      @user = @this_user
      handle_attribute_partials('edit')
    end
  end
  
  def update
    if params[:reset_password]
      load_user_using_perishable_token
    else
      require_user
      @user = @this_user # makes our views "cleaner" and more consistent
    end
    
    if params[:reset_password]
      @user.password = params[:user][:password]  
      @user.password_confirmation = params[:user][:password_confirmation]  
      if @user.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to root_url
      else  
      render :action => :edit  
      end
    elsif @user.update_attributes(params[:user])
      if params[:attribute]
        render :partial => 'show_' + params[:attribute] and return
      else
        redirect_to user_url(@this_user)
      end
    else
      render :action => :edit
    end
  end
  
  def forgot_password
    @user = User.new
  end

  def request_password_reset
    @user = User.find_by_email(params[:user][:email])
    @user.prepare_password_reset
    flash[:notice] = "We sent password reset instructions to your email address."
    redirect_to root_url and return
  end
  
  def activate
    if params[:validate_account]
      load_user_using_perishable_token
      @user.validate_account
      flash[:notice] = "We validated your account, welcome!"
      redirect_to root_url
    else
      redirect_to root_url
    end
  end
  
  private
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
    flash[:notice] = "We're sorry, but we could not locate your account. " +  
    "If you are having issues try copying and pasting the URL " +  
    "from your email into your browser or restarting the " +  
    "reset password process."  
    redirect_to root_url  
    end  
  end
end
