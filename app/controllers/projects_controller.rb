class ProjectsController < ApplicationController
  before_filter :require_user
  before_filter :get_project, :only => [:show,:edit,:comments,:update,:destroy,:archive_completed_tasks,:sort_tasks,:templatize]
  before_filter :set_nav_tab
  
  respond_to :html, :mobile
  
  def index
    @project = Project.new(:user_id => @this_user.id)
    @folders = @this_user.folders.ordered.includes(:projects)
    @sortable = true
    respond_with(@projects) do |format|
      format.any {render :action => 'index' and return}
    end
  end
  
  def archived
    @projects = Project.for_user(@this_user).only_once.archived.by_create_date.paginate(:page => params[:page],:per_page => 50)
  end
  
  def shared
    @friends_projects = @this_user.shared_projects.active.by_create_date.paginate(:page => params[:friends_page],:per_page => 50)
    @shared_projects = @this_user.projects.shared.active.ordered.paginate(:page => params[:shared_page],:per_page => 50)
  end
  
  def sort
    @projects = Project.find(params[:project].map{|p| p.to_i})
    @projects.each do |project|
      project.position = params[:project].index(project.id.to_s)
      project.save
    end
    render :text => '' and return
  end
  
  def templatize
    @project.generate_template
    @item = @project
    flash.now[:notice] = "We created a template for this plan. When creating future plans, you can choose to base them on this template now."
    @date_picker = true
    render :action => 'edit' and return
  end
  
  def archive_completed
    Project.for_user(@this_user).only_once.complete.each do |project|
      project.archive
      project.save
    end
    render :nothing => true and return
  end
  
  def create
    if @this_user.is_a? PaidAccount
      if params[:plan_template_id]
        @plan_template = PlanTemplate.find(params[:plan_template_id].to_i)
        @project = @plan_template.generate_plan
        @project.folder_id = params[:project][:folder_id]
        unless params[:project][:title].blank?
          @project.title = params[:project][:title]
        end
        @project.save
      else
        @project = Project.new(params[:project].merge!(:user_id => @this_user.id))
        @project.save
      end
      if(params[:return_to])
        @item = @project
        flash[:ajax_dialog] = render_to_string :partial => '/projects/go_to'
        @ajax_dialog_javascript = '/projects/go_to_javascript'
        redirect_to params[:return_to] + ((params[:return_to] =~ /\?/) ? '&' : '?' ) + "item_type=Project&item_id=#{@project.id}" and return
      else
        redirect_to plan_url(@project) and return
      end
    else
      flash[:notice] = "You need to upgrade to a paid account to create plans"
      redirect_to dashboard_url and return
    end
  end

  def show
    if params[:attribute]
      @item = @project
    end
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Plan'
    @sortable = true
    get_archived_tasks
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
    if params.has_key? :nullify
      @project.update_attributes({params[:attribute]=> nil})
      attribute = params[:attribute]
    elsif params[:sharer_email]
      @sharer = User.find(:first, :conditions => ["lower(email) = :sharer_email",{:sharer_email => params[:sharer_email].downcase}])
      if @sharer
        ProjectSharer.create(:user_id => @sharer.id,:project_id => @project.id)
        Notifier.share_plan(@project,@sharer).deliver
        flash.now[:ajax_notice] = "#{@sharer.handle} now has access to this list"
      else
        tmp_pass = User.generate_code(8)
        @sharer = FreeAccount.create(:email => params[:sharer_email], :password => tmp_pass, :password_confirmation => tmp_pass)
        ProjectSharer.create(:user_id => @sharer.id,:project_id => @project.id,:folder_id => @sharer.folder_ids.first)
        Notifier.share_plan(@project,@sharer,tmp_pass).deliver
        flash.now[:ajax_notice] = "We created a free account for #{params[:sharer_email]} and sent a welcome email including information about the plan you shared."
      end
      @project.sharers.reload
      attribute = 'sharing'
    else
      if params[:attribute]
        attribute = params[:attribute]
      else
        attribute = false
      end
      if(params[:shared_folder_id])
        project_sharer = @project.project_sharers.where(:user_id => @this_user.id).first
        project_sharer.folder_id = params[:shared_folder_id]
        project_sharer.save
      else
        @these_params = params[:project].dup
        @state_changed = @project.handle_attributes(@these_params)
        @project.save
      end
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
      if @render_type == :action
        get_archived_tasks
      end
      render @render_type => 'edit', :locals => {:project => @project, :sortable => (params.has_key? :sortable)}, :layout => (@render_type == :partial) ? "ajax_line_item" : 'application' and return
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
      @project.task_ids = params[:task].map{|tid| tid.to_i}
      tasks = @project.tasks
      tasks.each do |task|
        task.position = params[:task].index(task.id.to_s)
        task.save
      end
    end
    flash[:notice] = nil
    render :nothing => true and return
  end
  
  def get_archived_tasks
    @archived_tasks = @project.tasks.archived.ordered.paginate(:page => params[:page], :per_page => 50)
  end
  
  def get_project
    @project = Project.find(params[:id])
    @folder = @project.folder_for(@this_user)
    if (@project.user_id != @this_user.id) and (!@project.sharer_ids.include? @this_user.id)
      flash[:notice] = "You don't have privileges to access that project."
      redirect_to root_url and return
    end
  end
  
  def handle_title
    @html_page_title = @page_title = 'Plans'
  end
end