class ProjectSharersController < ApplicationController
  def create
    @project = Project.find(params[:project_sharer][:project_id])
    @sharer = User.find_by_email(params[:sharer_email])
    if @sharer
      ProjectSharer.create(:user_id => @sharer.id,:project_id => @project.id)
    else
      Notifier.share_plan(@project,params[:sharer_email])
      flash[:notice] = "We sent a copy of this plan to #{params[:sharer_email]} via email."
      
    end
  end
  
  def destroy
    @project_sharer = ProjectSharer.find(params[:id])
    @project_sharer.destroy
    render :nothing => true and return
  end
end