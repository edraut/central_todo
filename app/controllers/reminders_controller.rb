class RemindersController < ApplicationController
  before_filter :require_user
  before_filter :get_reminder, :only => [:show,:edit,:update,:destroy]
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def index
    @remindable_class = params[:remindable_type].constantize
    @remindable = @remindable_class.find(params[:remindable_id])
    respond_with(@remindable) do |format|
      format.any {render :partial => 'index', :locals => {:remindable => @remindable}}
      return
    end
    redirect_to root_url and return
  end
  
  def show
    respond_with(@reminder) do |format|
      format.any {render :partial => 'show', :locals => {:reminder => @reminder}}
    end
  end
  
  def create
    @reminder_class = params[:reminder][:type].constantize
    @reminder = @reminder_class.new(params[:reminder].merge(:user_id => @this_user.id))
    if @reminder.save
      respond_with(@reminder) do |format|
        format.any {render :partial => 'show', :locals => {:reminder => @reminder}, :layout => 'new_reminder'}
      end
    else
      respond_with(@reminder) do |format|
        format.any {render :partial => 'new', :locals => {:reminder => @reminder}}
      end
    end
  end
  
  def edit
    respond_with(@reminder) do |format|
      format.any {render :partial => 'edit', :locals => {:reminder => @reminder}}
    end
  end
  
  def update
    @reminder.attributes = params[:reminder]
    if @reminder.class.name != params[:reminder][:type]
      @reminder.type = params[:reminder][:type]
    end
    if @reminder.save
      @reminder = @reminder.type.constantize.find(@reminder.id)
      respond_with(@reminder) do |format|
        format.any {render :partial => 'show', :locals => {:reminder => @reminder}}
      end
    else
      respond_with(@reminder) do |format|
        format.any {render :partial => 'edit', :locals => {:reminder => @reminder}}
      end
    end
  end
  
  def destroy
    @reminder.destroy
    render :nothing => true and return
  end

  def get_reminder
    @reminder = Reminder.find(params[:id])
    if @reminder.user_id != @this_user.id
      flash[:notice] = "You don't have privileges to access that reminder."
      redirect_to root_url and return
    end
  end
end