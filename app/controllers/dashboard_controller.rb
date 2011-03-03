class DashboardController < ApplicationController
  respond_to :html, :mobile
  def index
    redirect_to root_url and return unless @this_user
    @page_title = 'Dashboard'
    @task = Task.new(:user_id => @this_user.id)
    @due_date_tasks = @this_user.tasks.active.with_due_date.by_due_date.five
    @due_date_projects = @this_user.projects.active.with_due_date.by_due_date.five
    @due_date_items = (@due_date_projects + @due_date_tasks)
    @due_date_items.sort!{|a,b| a.due_date <=> b.due_date}
    @due_dates = @due_date_items.map{|t| t.due_date.to_date}.uniq
    respond_with(@task) do |format|
      format.mobile { render @render_type => 'index', :layout => @this_layout}
      format.html {render @render_type => 'index'}
    end
  end
end