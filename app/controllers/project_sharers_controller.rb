class ProjectSharersController < ApplicationController
  def create
    @project = Project.find(params[:project_sharer][:project_id])
    @sharer = User.find_by_email(params[:sharer_email])
    if @sharer
      ProjectSharer.create(:user_id => @sharer.id,:project_id => @project.id)
    else
      tmp_pass = User.generate_code(8)
      @sharer = FreeAccount.create(:email => params[:sharer_email], :password => tmp_pass, :password_confirmation => tmp_pass)
      Notifier.share_plan(@project,@sharer)
      flash[:notice] = "We created a free account for #{params[:sharer_email]} and sent a welcome email including information about the plan you shared."
    end
  end
  
  def destroy
    @project_sharer = ProjectSharer.find(params[:id])
    @project_sharer.destroy
    render :nothing => true and return
  end
end