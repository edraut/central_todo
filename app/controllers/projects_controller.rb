class ProjectsController < ApplicationController
  before_filter :require_user
  before_filter :get_project, :only => [:show,:edit,:comments,:update,:destroy,:archive_completed_tasks,:sort_tasks]
  
  respond_to :html, :mobile
  
  def index
    @project = Project.new(:user_id => @this_user.id)
    @projects = @this_user.projects.unarchived.ordered.paginate(:page => params[:page], :per_page => 40)
    @sortable = true
    respond_with(@projects) do |format|
      format.any {render :action => 'index' and return}
    end
  end
  
  def archived
    @projects = Project.for_user(@this_user).archived.by_create_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def shared
    @projects = @this_user.shared_projects.active.by_create_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def sort
    projects = @this_user.projects.active
    projects.each do |project|
      project.position = params[:project].index(project.id.to_s)
      project.save
    end
  end
  
  def archive_completed
    Project.for_user(@this_user).complete.each do |project|
      project.archive
      project.save
    end
    render :nothing => true and return
  end
  
  def create
    @project = Project.new(params[:project])
    @project.save
    redirect_to plan_url(@project) and return
  end

  def show
    @item = @project
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Plan'
    @sortable = true
    @task = Task.new(:user_id => @this_user.id, :project_id => @project.id)
    @archived_tasks = @project.tasks.archived.ordered.paginate(:page => params[:page], :per_page => 40)
  end
  
  def edit
    @item = @project
    @date_picker = true
    return if handle_attribute_partials('edit')
  end
  
  def comments
    @comments = @project.comments.by_date
  end
  
  def update
    if params[:sharer_email]
      @sharer = User.find(:first, :conditions => ["lower(email) = :sharer_email",{:sharer_email => params[:sharer_email].downcase}])
      if @sharer
        ProjectSharer.create(:user_id => @sharer.id,:project_id => @project.id)
        flash.now[:ajax_notice] = "#{@sharer.email} now has access to this list"
      else
        ProjectEmail.create(:project_id => @project.id,:email => params[:sharer_email])
        Notifier.share_plan(@project,params[:sharer_email]).deliver
        flash.now[:ajax_notice] = "We sent a copy of this plan to #{params[:sharer_email]} via email."
      end
      @project.sharers.reload
      attribute = 'sharing'
    else
      if params[:attribute]
        attribute = params[:attribute]
      else
        attribute = false
      end
      @these_params = params[:project].dup
      @state_changed = @project.handle_attributes(@these_params)
      @project.save
      flash.now[:ajax_notice] = "Your changes were saved."
    end
    @item = @project
    if attribute
      respond_with(@project) do | format |
        format.any {render :partial => 'show_' + attribute, :locals => {:project => @project}, :layout => 'ajax_section' and return}
      end
      return
    else
      @item = @project
      render @render_type => 'show', :locals => {:project => @project, :sortable => (params.has_key? :sortable)}, :layout => 'ajax_line_item' and return
    end
  end
  
  def destroy
    if @project.user_id == @this_user.id
      @project.destroy
    else
      @project_sharer = @this_user.project_sharers.find(:first, :conditions => {:project_id => @project.id})
      @project_sharer.destroy
    end
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
      flash.now[:notice] = "These tasks are now sorted by due date."
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
    if (@project.user_id != @this_user.id) and (!@project.sharer_ids.include? @this_user.id)
      flash[:notice] = "You don't have privileges to access that project."
      redirect_to root_url and return
    end
  end
  
  def handle_title
    @html_page_title = @page_title = 'Plans'
  end
end