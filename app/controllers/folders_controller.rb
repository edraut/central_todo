class FoldersController < ApplicationController
  before_filter :require_user
  before_filter :get_folder, :only => [:show,:edit,:update,:destroy,:sort_plans]
  before_filter :set_nav_tab
  
  respond_to :html, :mobile
  
  def sort
    @folders = Folder.find(params[:folder].map{|p| p.to_i})
    @folders.each do |folder|
      folder.position = params[:folder].index(folder.id.to_s)
      folder.save
    end
    render :nothing => true and return
  end
  
  def create
    if @this_user.is_a? PaidAccount
      @folder = Folder.new(params[:folder].merge!(:user_id => @this_user.id))
      unless @folder.save
        flash[:notice] = @folder.errors.full_messages
      end
    else
      flash[:notice] = "You need to upgrade to a paid account to create folders"
      redirect_to dashboard_url and return
    end
    if(params[:return_to])
      redirect_to params[:return_to] and return
    else
      redirect_to plans_url
    end
  end

  def sort_plans
    if params[:by_due_date]
      no_date_offset = @folder.projects.with_due_date.count
      @folder.projects.without_due_date.ordered.each_with_index do |project,index|
        project.position = index + no_date_offset
        project.save
      end
      @folder.projects.with_due_date.by_due_date.each_with_index do |project,index|
        project.position = index
        project.save
      end
      flash.now[:notice] = "These projects are now sorted by due date."
      show
      render :action => 'show' and return
    else
      all_projects = Project.find(params[:project].map{|pid| pid.to_i})
      owned_projects = all_projects.select{|p| p.user_id == @this_user.id}
      shared_projects = all_projects - owned_projects
      shared_projects.each do |shared_project|
        project_sharer = shared_project.project_sharers.where(:user_id => @this_user.id).first
        project_sharer.folder = @folder
        project_sharer.position = params[:project].index(shared_project.id.to_s + 'nav')
        project_sharer.save
      end
      @folder.project_ids = owned_projects.map{|op| op.id}
      owned_projects.each do |project|
        project.update_attributes(:position => params[:project].index(project.id.to_s + 'nav'))
      end
    end
    render :nothing => true and return
  end
  
  def destroy
    @folder.destroy
    render :nothing => true and return
  end
  
  def show
  end
  
  def handle_title
    @html_page_title = @page_title = 'Plans'
  end
  
  def get_folder
    @folder = Folder.find(params[:id])
  end
end