class ProjectSharersController < ApplicationController
  def update
    @project_sharer = ProjectSharer.find(params[:id])
    @project_sharer.update_attributes(params[:project_sharer])
    render :nothing => true and return
  end
  
  def destroy
    @project_sharer = ProjectSharer.find(params[:id])
    @project_sharer.destroy
    render :nothing => true and return
  end
end