class LabelsController < ApplicationController
  before_filter :require_user
  before_filter :handle_tos
  before_filter :require_valid_account
  before_filter :get_label, :only => [:show,:edit,:update,:destroy,:archive_completed_tasks,:sort_tasks,:show_full]
  before_filter :set_nav_tab
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  respond_to :html, :mobile
  
  def index
    @label = Label.new(:user_id => @this_user.id)
    respond_with(@label) do |format|
      format.mobile { render @render_type => 'index'}
      format.html {render :action => 'index' and return}
    end
  end
  
  def multiple
    @labels = Label.ordered.find(params[:ids].split(',').map{|id| id.to_i})
    respond_with(@labels) do |format|
      format.mobile {render :partial => 'show_multiple' and return}
    end
  end
  
  def create
    @label = Label.new(params[:label].merge!(:user_id => @this_user.id))
    @label.save
    if params[:return_to]
      redirect_to params[:return_to] and return
    end
    redirect_to :action => 'index' and return
  end

  def show
    @item = @label
    return if handle_attribute_partials('show')
    prepare_label
    respond_with(@label) and return
  end
  
  def show_full
    prepare_label
    if @render_type == :partial
      respond_with(@label) do |format|
        format.any {render @render_type => 'show_full' and return}
      end
    else
      respond_with(@label) do |format|
        format.any {render @render_type => 'show' and return}
      end
    end
  end
  
  def edit
    @item = @label
    return if handle_attribute_partials('edit')
    respond_with(@label) do |format|
      format.mobile { render @render_type => 'edit', :locals => {:label => @label}}
      format.html {render @render_type => 'edit'}
    end
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
    @user = @label.user
    unless @label.user_id == @this_user.id or @this_user.sharing_parents.map{|sp| sp.id}.include? @label.user_id
      flash[:notice] = "You don't have privileges to access that label."
      redirect_to root_url and return
    end
  end
  
  def prepare_label
    @html_page_title = @page_title = 'Label'
    @sortable = true
    if @label.user_id == @this_user.id
      @tasks = @label.tasks.active.ordered.paginate(:page => params[:page],:per_page => 40)
    else
      @tasks = Task.only_once.for_user(@this_user).for_label(@label).active.ordered.paginate(:page => params[:page],:per_page => 40)
    end
  end
end
