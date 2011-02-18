class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end
  
  def update
    if params[:time_zone_offset]
      session[:time_zone_offset] = params[:time_zone_offset]
    end
    redirect_back_or_default(root_url)
  end
  
  def show
    update
  end
  
  def destroy
    current_user_session.destroy
    redirect_back_or_default new_user_session_url
  end
end
