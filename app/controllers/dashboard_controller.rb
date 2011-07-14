class DashboardController < ApplicationController
  before_filter :require_user
  before_filter :handle_tos
  before_filter :set_nav_tab
  respond_to :html, :mobile
  def index
    @page_title = 'Dashboard'
    @task = Task.new(:user_id => @this_user.id)
    @priority_tasks = Task.only_once.for_user(@this_user).active.priority.recent.three
    if @priority_tasks.length == 3
      @total_priority_task_count = Task.only_once.for_user(@this_user).active.priority.count
    else
      @total_priority_task_count = @priority_tasks.length
    end
    @due_date_tasks = Task.only_once.for_user(@this_user).active.with_due_date.by_due_date.find(:all, :limit => 2)
    if @due_date_tasks.length == 2
      @due_date_task_count = Task.only_once.for_user(@this_user).active.with_due_date.count
    else
      @due_date_task_count = @due_date_tasks.length
    end
    @due_date_projects = Project.for_user(@this_user).only_once.active.with_due_date.by_due_date.find(:all, :limit => 2)
    if @due_date_projects.length == 2
      @due_date_project_count = Task.only_once.for_user(@this_user).active.with_due_date.count
    else
      @due_date_project_count = @due_date_projects.length
    end
    @due_date_items = (@due_date_projects + @due_date_tasks)
    @due_date_items.sort!{|a,b| a.due_date <=> b.due_date}
    @due_dates = @due_date_items.map{|t| t.due_date.to_date}.uniq
    respond_with(@task) do |format|
      format.mobile { render @render_type => 'index', :layout => @this_layout}
      format.html {render @render_type => 'index'}
    end
  end
  
  def completed
    @tasks = Task.for_user(@this_user).only_once.complete.recent.five.all
    @projects = Project.for_user(@this_user).only_once.complete.recent.five.all
    render @render_type => 'completed'
  end
  
  def unorganized
    @tasks = @this_user.tasks.unarchived.unorganized.recent.paginate(:page => params[:page],:per_page => 25)
    @projects = Project.unorganized_for(@this_user).active.recent.paginate(:page => params[:plan_page],:per_page => 25)
    respond_with(@tasks) do |format|
      format.mobile { render @render_type => 'unorganized'}
      format.html {render @render_type => 'unorganized'}
    end
  end
end