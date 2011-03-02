class ProjectsController < ApplicationController
  before_filter :require_user
  before_filter :get_project, :only => [:show,:edit,:update,:destroy,:archive_completed_tasks,:sort_tasks]
  
  respond_to :html, :mobile
  
  def index
    @project = Project.new(:user_id => @this_user.id)
    @projects = Project.unarchived.ordered.paginate(:page => params[:page], :per_page => 40, :conditions => {:user_id => @this_user.id})
    @sortable = true
    respond_with(@projects) do |format|
      format.any {render :action => 'index' and return}
    end
  end
  
  def archived
    @projects = @this_user.projects.archived.by_create_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def sort
    projects = @this_user.projects.active
    projects.each do |project|
      project.position = params[:project].index(project.id.to_s)
      project.save
    end
  end
  
  def archive_completed
    @this_user.projects.complete.each do |project|
      project.archive
      project.save
    end
    render :nothing => true and return
  end
  
  def create
    @project = Project.new(params[:project])
    @project.save
    redirect_to :action => 'index' and return
  end

  def show
    @item = @project
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Plan'
    @sortable = true
    @task = Task.new(:user_id => @this_user.id, :project_id => @project.id)
    @archived_tasks = @project.tasks.archived.ordered.paginate(:page => params[:page], :per_page => 40)
    if params[:_method]
      if ['PUT','put'].include? params[:_method]
        update and return
      end
    end
  end
  
  def edit
    @item = @project
    return if handle_attribute_partials('edit')
  end
  
  def update
    @these_params = params[:project].dup
    @state_changed = @project.handle_attributes(@these_params)
    @project.save
    @item = @project
    if params[:attribute]
      flash[:ajax_notice] = "Your changes were saved"
      respond_with(@project) do | format |
        format.any {render :partial => 'show_' + params[:attribute], :locals => {:project => @project}, :layout => 'ajax_section' and return}
      end
      return
    else
      @item = @project
      render @render_type => 'show', :locals => {:project => @project, :sortable => (params.has_key? :sortable)}, :layout => 'ajax_line_item' and return
    end
  end
  
  def destroy
    @project.destroy
    flash[:notice] = "Your project was successfully deleted."
    redirect_to :action => 'index' and return
  end
  
  def archive_completed_tasks
    @project.tasks.complete.each do |task|
      task.archive
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
  
  def handle_title
    @html_page_title = @page_title = 'Plans'
  end
end