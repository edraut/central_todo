class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_task, :only => [:show,:comments,:edit,:update,:destroy,:convert]
  before_filter :set_nav_tab
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def index
    @page_title = "Tasks"
    @tasks = @this_user.tasks.unarchived.unorganized.paginate(:page => params[:page],:per_page => 40)
    respond_with(@tasks) do |format|
      format.mobile { render @render_type => 'index', :layout => @this_layout}
      format.html {render @render_type => 'index'}
    end
  end
  
  def priority
    @tasks = Task.for_user(@this_user).active.priority.paginate(:page => params[:page],:per_page => 40)
  end
    
  def archived_unorganized
    @tasks = @this_user.tasks.unorganized.archived.paginate(:page => params[:page],:per_page => 40)
  end

  def due_date
    @tasks = @this_user.tasks.active.with_due_date.by_due_date.paginate(:page => params[:page],:per_page => 40)
  end
  
  def archive_completed
    if @this_user.tasks.unorganized.complete.update_all :state => 'archived'
      render :nothing => true and return
    else
      render :text => "Oops! We couldn't archive those completed tasks, please contact customer support.", :status => 500
    end
  end
  
  def create
    project_id = params[:task][:project_id]
    if params.has_key? :title_1
      @tasks = []
      for title in [params[:title_1],params[:title_2],params[:title_3]]
        unless title.blank?
          @tasks.push Task.create(params[:task].merge(:title => title))
        end
      end
      @task = @tasks.detect{|t| !t.title.blank?}
    else
      @task = Task.new(params[:task])
      if @task.user_id != @this_user.id
        flash[:notice] = "You can't create tasks for other users, please try again."
        redirect_to dashboard_url and return
      end
      @task.save
    end
    if params[:app_context]
      case params[:app_context]
      when 'project'
        flash[:notice] = "Another task well organized!"
        redirect_to plan_url(project_id) + '?added_task=true' and return
      end
    else
      redirect_to dashboard_url
    end
  end

  def show
    @item = @task
    @date_picker = true
    if params[:full_view]
      respond_with(@task) do |format|
        format.html {render :partial => 'full_view' and return}
      end
      return
    end
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Task'
    respond_with(@task)
  end
  
  def comments
    @comments = @task.comments.by_date
  end
  
  def edit
    @item = @task
    return if handle_attribute_partials('edit')
  end
  
  def update
    if params.has_key? :nullify
      @task.update_attributes({params[:attribute]=> nil})
    elsif params.has_key? :attribute and params[:attribute] == 'labels'
      label_ids = params[:labels]
      label_ids ||= []
      old_task_labels = @this_user.task_labels.for_task(@task)
      old_label_ids = old_task_labels.map{|ts| ts.label_id}
      new_label_ids = label_ids - old_label_ids
      delete_label_ids = old_label_ids - label_ids
      for id in delete_label_ids
        old_task_labels.detect{|ots| ots.label_id == id}.destroy
      end
      for id in new_label_ids
        TaskLabel.create(:task_id => @task.id,:label_id => id)
      end
      @task.task_labels.reload
    else
      @these_params = params[:task].dup
      @state_changed = @task.handle_attributes(@these_params)
      if(params.has_key? :app_context)
        @app_context = params[:app_context]
        if (params[:app_context] == 'project' and @state_changed == 'archived')
          @move = true
        end
      end
      @task.update_attributes(@these_params)
    end
    @item = @task
    if params[:attribute]
      if !@state_changed
        if params[:attribute] == 'priority'
          flash.now[:ajax_notice] = "Saved!"
        else
          flash.now[:ajax_notice] = "Your changes were saved"
        end
      end
      respond_with(@task) do | format |
        format.any {render :partial => 'show_' + params[:attribute], :locals => {:task => @task, :foo => 'bar'}, :layout => 'ajax_section' and return}
      end
    else
      if @render_type == :partial
        flash[:ajax_notice] = "Your changes were saved."
      end
      @item = @task
      respond_with(@task) do | format |
        format.any {render @render_type => 'show', :layout => "ajax_line_item", :locals => {:task => @task, :sortable => (params.has_key? :sortable), :needs_organization => (params.has_key? :needs_organization)} and return}
      end
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
      render :nothing => true, :status => 200 and return
    end
    flash[:notice] = "Your task was successfully deleted."
    redirect_to (session[:return_to] || dashboard_url) and return
  end
  
  def get_task
    @task = Task.find(params[:id])
    @project = @task.project
    if @task.user_id != @this_user.id and (!@task.project.sharer_ids.include? @this_user.id)
      flash[:notice] = "You don't have privileges to access that task."
      redirect_to root_url and return
    end
  end
  
end