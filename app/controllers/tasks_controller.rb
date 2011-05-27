class TasksController < ApplicationController
  before_filter :require_user
  before_filter :get_task, :only => [:show,:comments,:edit,:update,:destroy,:convert]
  before_filter :set_nav_tab
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def priority
    @tasks = Task.only_once.for_user(@this_user).active.priority.paginate(:page => params[:page],:per_page => 40)
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
  
  def multiple
    @tasks = Task.recent.find(params[:ids].split(',').map{|id| id.to_i})
    respond_with(@tasks) do |format|
      format.mobile {render :partial => 'show_full' and return}
    end
  end
  
  def multiple_comments
    @tasks = Task.recent.find(params[:ids].split(',').map{|id| id.to_i})
    respond_with(@tasks) do |format|
      format.mobile {render :partial => 'multiple_comments' and return}
    end
  end
  
  def create
    project_id = params[:task][:project_id]
    @project = Project.find(project_id.to_i) if project_id
    if params.has_key? :title_1
      @tasks = []
      for title in [params[:title_1],params[:title_2],params[:title_3]]
        unless title.blank?
          task = Task.create(params[:task].merge!(:title => title,:user_id => @this_user.id))
          @tasks.push task
        end
      end
      @task = @tasks.detect{|t| !t.title.blank?}
    else
      @task = Task.new(params[:task].merge!(:user_id => @this_user.id))
      if @task.user_id != @this_user.id
        flash[:notice] = "You can't create tasks for other users, please try again."
        redirect_to dashboard_url and return
      end
      @task.save
    end
    if params[:app_context]
      @app_context = params[:app_context]
      @item = @task
      case params[:app_context]
      when 'project'
        if @task.project.task_ids.count > 5
          flash.now[:ajax_dialog] = render_to_string :partial => '/tasks/move_to_top'
          @ajax_dialog_javascript = '/tasks/move_to_top_javascript'
        end
        render :partial => 'show', :locals => {:task => @task, :project => @project, :sortable => true}, :layout => 'new_task'
      when 'hierarchical'
        render :partial => 'show', :locals => {:task => @task, :project => @project, :hierarchical => true}, :layout => 'new_task'
      end
    else
      @app_context = nil
      if(params[:return_to])
        flash[:notice] = "Your task was successfully created."
        redirect_to params[:return_to] and return
      else
        redirect_to dashboard_url + '?added_task=true'
      end
    end
  end

  def show
    @date_picker = true
    if params[:attribute]
      @item = @task
    end
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Task'
    respond_with(@task) do |format|
      format.mobile { render @render_type => 'show', :locals => {:task => @task}}
      format.html {render @render_type => 'show'}
    end
  end
  
  def comments
    respond_with(@task) do |format|
      format.mobile { render @render_type => 'comments', :locals => {:task => @task}}
      format.html {render @render_type => 'comments'}
    end
  end
  
  def edit
    @item = @task
    return if handle_attribute_partials('edit')
  end
  
  def update
    if(params.has_key? :partial and params.has_key? :app_context)
      @app_context = params[:app_context]
    end
    if params.has_key? :nullify
      @task.update_attributes({params[:attribute]=> nil})
    elsif (params.has_key? :attribute and params[:attribute] == 'labels') or ( params.has_key? :has_labels and params.has_key? :partial)
      label_ids = params[:labels]
      label_ids ||= []
      label_ids = label_ids.map{|lid| lid.to_i}
      old_labels = @task.labels.for_user(@this_user)
      old_label_ids = old_labels.map{|l| l.id}
      new_label_ids = label_ids - old_label_ids
      delete_label_ids = old_label_ids - label_ids
      for id in delete_label_ids
        @task.task_labels.where(:label_id => id).each{|l| l.destroy}
      end
      for id in new_label_ids
        TaskLabel.create(:task_id => @task.id,:label_id => id)
      end
      @task.labels.reload
    else
      @these_params = params[:task].dup
      @state_changed = @task.handle_attributes(@these_params)
      if (params[:app_context] == 'project' and @state_changed == 'archived')
        @move = true
      end
      @task.update_attributes(@these_params)
      @task.reload
      @project = @task.project
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
        format.any {render @render_type => 'show', :layout => (@render_type == :partial) ? "ajax_line_item" : 'application', :locals => {:task => @task, :sortable => (params.has_key? :sortable), :needs_organization => (params.has_key? :needs_organization), :hierarchical => (params.has_key? :hierarchical)} and return}
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
      flash.now[:notice] = "Your task was successfully deleted."
      render :nothing => true, :status => 200 and return
    end
    flash[:notice] = "Your task was successfully deleted."
    redirect_to (session[:return_to] || dashboard_url) and return
  end
  
  def get_task
    @task = Task.find(params[:id])
    if @task.class.name == 'Array'
      @tasks = @task
    end
    @project = @task.project
    if(@project)
      @folder = @project.folder_for(@this_user)
    end
    if @task.user_id != @this_user.id and (!(@task.project.sharer_ids + [@task.project.user_id]).include? @this_user.id)
      flash[:notice] = "You don't have privileges to access that task."
      redirect_to root_url and return
    end
  end
  
end