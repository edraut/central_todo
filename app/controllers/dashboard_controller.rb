class DashboardController < ApplicationController
  def index
    @task = Task.new(:user_id => @this_user.id)
  end
end