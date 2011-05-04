class DashboardController < ApplicationController
  before_filter :require_user
  before_filter :set_nav_tab
  respond_to :html, :mobile
  def index
    @page_title = 'Dashboard'
    @task = Task.new(:user_id => @this_user.id)
    @priority_tasks = Task.only_once.for_user(@this_user).active.priority.recent.five
    if @priority_tasks.length > 4
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
end