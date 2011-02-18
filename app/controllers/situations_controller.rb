class SituationsController < ApplicationController
  before_filter :require_user
  before_filter :get_situation, :only => [:show,:edit,:update,:destroy,:retire_completed_tasks,:sort_tasks]
  
  def index
    @situation = Situation.new(:user_id => @this_user.id)
  end
  
  def create
    @situation = Situation.new(params[:situation])
    @situation.save
    index
    render :action => 'index' and return
  end

  def show
    handle_attribute_partials('show')
    @sortable = true
    @task = Task.new(:user_id => @this_user.id, :situation_id => @situation.id)
    if params[:_method]
      if ['PUT','put'].include? params[:_method]
        update and return
      end
    end
  end
  
  def edit
    handle_attribute_partials('edit')
  end
  
  def update
    @situation.update_attributes(params[:situation])
    if params[:attribute]
      render :partial => 'show_' + params[:attribute], :locals => {:situation => @situation}, :layout => 'ajax_section' and return
    else
      render :action => 'show' and return
    end
  end
  
  def retire_completed_tasks
    if @situation.tasks.complete.update_all :retired => true
      render :nothing => true and return
    else
      render :text => "Oops! We couldn't retire those completed tasks, please contact customer support.", :status => 500
    end
  end
  
  def destroy
    @situation.destroy
    index
    flash[:notice] = "Your situation was successfully deleted."
    render :action => 'index' and return
  end
    
  def get_situation
    @situation = Situation.find(params[:id])
    unless @situation.user_id == @this_user.id
      flash[:notice] = "You don't have privileges to access that situation."
      redirect_to root_url and return
    end
  end
end
