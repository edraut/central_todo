class LabelsController < ApplicationController
  before_filter :require_user
  before_filter :get_label, :only => [:show,:edit,:update,:destroy,:archive_completed_tasks,:sort_tasks]
  before_filter :set_nav_tab
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def index
    @label = Label.new(:user_id => @this_user.id)
    respond_with(@label) and return
  end
  
  def create
    @label = Label.new(params[:label].merge!(:user_id => @this_user.id))
    @label.save
    redirect_to :action => 'index' and return
  end

  def show
    @item = @label
    return if handle_attribute_partials('show')
    @html_page_title = @page_title = 'Label'
    @sortable = true
    @tasks = @label.tasks.active.ordered.paginate(:page => params[:page],:per_page => 40)
    respond_with(@label) and return
  end
  
  def edit
    @item = @label
    return if handle_attribute_partials('edit')
  end
  
  def update
    @item = @label
    @label.update_attributes(params[:label])
    if params[:attribute]
      respond_with(@label) do | format |
        format.any {render :partial => 'show_' + params[:attribute], :locals => {:label => @label}, :layout => 'ajax_section' and return}
      end
      return
    else
      render :action => 'show' and return
    end
  end
  
  def archive_completed_tasks
    if @label.tasks.complete.update_all :archived => true
      render :nothing => true and return
    else
      render :text => "Oops! We couldn't archive those completed tasks, please contact customer support.", :status => 500
    end
  end
  
  def destroy
    @label.destroy
    flash[:notice] = "Your label was successfully deleted."
    redirect_to :action => 'index' and return
  end
    
  def get_label
    @label = Label.find(params[:id])
    unless @label.user_id == @this_user.id
      flash[:notice] = "You don't have privileges to access that label."
      redirect_to root_url and return
    end
  end
end
