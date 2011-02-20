class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_task, :only => [:show,:edit,:update,:destroy,:convert]
  before_filter :handle_broken_browser_methods, :only => [:show, :create]
  
  def index
    unorganized
    render :action => 'unorganized'
  end
  
  def priority
    @tasks = @this_user.tasks.active.priority.paginate(:page => params[:page],:per_page => 40)
  end
  
  def unorganized
    @filter = 'unorganized'
  end
  
  def retired_unorganized
    @tasks = @this_user.tasks.unorganized.retired.paginate(:page => params[:page],:per_page => 40)
  end

  def due_date
    @tasks = @this_user.tasks.active.with_due_date.by_due_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def retire_completed
    if @this_user.tasks.one_off.complete.update_all :state => 'retired'
      render :nothing => true and return
    else
      render :text => "Oops! We couldn't retire those completed tasks, please contact customer support.", :status => 500
    end
  end
  
  def create
    @task = Task.new(params[:task])
    if @task.user_id != @this_user.id
      flash[:notice] = "You can't create tasks for other users, please try again."
      redirect_to dashboard_url and return
    end
    @task.save
    if params[:app_context]
      case params[:app_context]
      when 'situation'
        flash[:notice] = "It's on your list now."
        redirect_to situation_url(@task.situation_id) and return
      when 'project'
        flash[:notice] = "Another task well organized!"
        redirect_to plan_url(@task.project) and return
      end
    else
      unorganized
      render :action => 'unorganized'
    end
  end

  def show
    handle_attribute_partials('show')
  end
  
  def edit
    handle_attribute_partials('edit')
  end
  
  def update
    if params[:partial]
      render_type = :partial
    else
      render_type = :action
    end
    @task.attributes = (params[:task])
    @state_changed = @task.state_changed?
    @task.save
    if params[:attribute]
      render :partial => 'show_' + params[:attribute], :locals => {:task => @task}, :layout => 'ajax_section' and return
    else
      @item = @task
      render render_type => 'show', :locals => {:task => @task, :sortable => (params.has_key? :sortable), :needs_organization => (params.has_key? :needs_organization)}, :layout => 'ajax_line_item' and return
    end
  end
  
  def convert
    plan = Project.create(:title => @task.title, :description => @task.description, :user_id => @this_user.id)
    @task.destroy
    redirect_to plan_url(plan)
  end
  
  def destroy
    @task.destroy
    if request.xhr?
      render :nothing => true and return
    end
    index
    flash[:notice] = "Your task was successfully deleted."
    render :action => 'index' and return
  end
  
  def get_task
    @task = Task.find(params[:id])
    unless @task.user_id == @this_user.id
      flash[:notice] = "You don't have privileges to access that task."
      redirect_to root_url and return
    end
  end
  
end