class ProjectsController < ApplicationController
  before_filter :require_user
  before_filter :get_project, :only => [:show,:edit,:update,:destroy,:retire_completed_tasks,:sort_tasks]
  
  def index
    @project = Project.new(:user_id => @this_user.id)
    @sortable = true
  end
  
  def retired
    @projects = @this_user.projects.retired.by_create_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def sort
    projects = @this_user.projects.incomplete
    projects.each do |project|
      project.position = params[:project].index(project.id.to_s)
      project.save
    end
  end
  
  def retire_completed
    @this_user.projects.complete.each do |project|
      project.retire
      project.save
    end
    render :nothing => true and return
  end
  
  def create
    @project = Project.new(params[:project])
    @project.save
    index
    render :action => 'index' and return
  end

  def show
    handle_attribute_partials('show')
    @sortable = true
    @task = Task.new(:user_id => @this_user.id, :project_id => @project.id)
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
    if params[:partial]
      render_type = :partial
    else
      render_type = :action
    end
    @these_params = params[:project].dup
    @state_changed = @project.handle_attributes(@these_params)
    @project.save
    if params[:attribute]
      render :partial => 'show_' + params[:attribute], :locals => {:project => @project}, :layout => 'ajax_section' and return
    else
      @item = @project
      render render_type => 'show', :locals => {:project => @project, :sortable => (params.has_key? :sortable)}, :layout => 'ajax_line_item' and return
    end
  end
  
  def destroy
    @project.destroy
    index
    flash[:notice] = "Your project was successfully deleted."
    render :action => 'index' and return
  end
  
  def retire_completed_tasks
    @project.tasks.complete.each do |task|
      task.retire
      task.save
    end
    render :nothing => true and return
  end
  
  def sort_tasks
    if params[:by_due_date]
      no_date_offset = @project.tasks.with_due_date.count
      @project.tasks.without_due_date.ordered.each_with_index do |task,index|
        task.position = index + no_date_offset
        task.save
      end
      @project.tasks.with_due_date.by_due_date.each_with_index do |task,index|
        task.position = index
        task.save
      end
      flash[:notice] = "These tasks are now sorted by due date."
      show
      render :action => 'show' and return
    else
      tasks = @project.tasks
      tasks.each do |task|
        task.position = params[:task].index(task.id.to_s)
        task.save
      end
    end
    flash[:notice] = nil
    render :nothing => true and return
  end
  
  def get_project
    @project = Project.find(params[:id])
    unless @project.user_id == @this_user.id
      flash[:notice] = "You don't have privileges to access that project."
      redirect_to root_url and return
    end
  end
end