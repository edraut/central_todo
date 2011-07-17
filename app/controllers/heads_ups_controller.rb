class HeadsUpsController < ApplicationController
  before_filter :require_user
  before_filter :get_heads_up, :only => [:show,:edit,:update,:destroy]
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def create
    @heads_up = HeadsUp.where(params[:heads_up].merge(:user_id => @this_user.id)).first
    @heads_up ||= HeadsUp.create(params[:heads_up].merge(:user_id => @this_user.id))
    render :partial => 'show_notifications', :locals => {:alertable => @heads_up.alertable} and return
  end
  
  def destroy
    old_alertable = @heads_up.alertable
    @heads_up.destroy
    alertable = old_alertable.class.find(old_alertable.id)
    render :partial => 'show_notifications', :locals => {:alertable => alertable} and return
  end
  
  def get_heads_up
    @heads_up = HeadsUp.find(params[:id])
    if @heads_up.user_id != @this_user.id
      redirect_to dashboard_url and return
    end
  end
end