class DashboardController < ApplicationController
  respond_to :html, :mobile
  def index
    redirect_to root_url and return unless @this_user
    @page_title = 'Dashboard'
    @task = Task.new(:user_id => @this_user.id)
    respond_with(@task) do |format|
      format.mobile { render @render_type => 'index', :layout => @this_layout}
      format.html {render @render_type => 'index'}
    end
  end
end