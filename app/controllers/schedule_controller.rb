class ScheduleController < ApplicationController
  before_filter :require_user
  
  def index
    current_page = params[:page]
    current_page ||= 1
    current_page = current_page.to_i
    offset = (current_page - 1) * 25
    sql = %Q`SELECT projects.id as id, "projects".title as title, projects.state as state, projects.user_id as user_id, projects.due_date as due_date, 'Project' as item_type FROM "projects" WHERE ("projects".user_id = #{@this_user.id}) AND (projects.state = 'active') AND (projects.due_date is not null) UNION SELECT projects.id as id, "projects".title as title, projects.state as state, projects.user_id as user_id, projects.due_date as due_date, 'Project' as item_type FROM "projects" inner join project_sharers on project_sharers.project_id = projects.id WHERE project_sharers.user_id = #{@this_user.id} AND (projects.state = 'active') AND (projects.due_date is not null) UNION SELECT tasks.id as id, "tasks".title as title, tasks.state as state, tasks.user_id as user_id, tasks.due_date as due_date, 'Task' as item_type FROM "tasks" WHERE ("tasks".user_id = #{@this_user.id}) AND (tasks.state = 'active') AND (tasks.due_date is not null) UNION SELECT tasks.id as id, "tasks".title as title, tasks.state as state, tasks.user_id as user_id, tasks.due_date as due_date, 'Task' as item_type FROM "tasks" inner join project_sharers on project_sharers.project_id = tasks.project_id WHERE project_sharers.user_id = #{@this_user.id}  AND (tasks.state = 'active') AND (tasks.due_date is not null) ORDER BY due_date LIMIT 25 OFFSET #{offset};`
    @sql_items = Task.connection.select_all(sql)
    @due_date_items = WillPaginate::Collection.create(current_page, 25, @sql_items.length) do |pager|
       pager.replace(@sql_items)
    end
    @due_dates = @due_date_items.map{|t| t['due_date'].to_date}.uniq    
  end
end