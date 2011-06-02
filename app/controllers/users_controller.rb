class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :show
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  before_filter :set_nav_tab
  respond_to :html, :mobile
  
  def index
    @sharing_parents = User.sharing_parents_for(@this_user)
    @sharing_children = User.sharing_children_for(@this_user)
    respond_with(@sharing_parents) do |format|
      format.mobile { render @render_type => 'index'}
      format.html {render :action => 'index' and return}
    end
  end

  def multiple
    @contacts = User.order('users.id').find(params[:ids].split(',').map{|id| id.to_i})
    respond_with(@contacs) do |format|
      format.mobile {render :partial => 'show_multiple' and return}
    end
  end
  
  def new
    @user = User.new
    @page_heading = "Create your toDo account"
    respond_with(@user) do |format|
      format.mobile { render @render_type => 'new', :layout => @this_layout and return }
    end
  end
  
  def create
    rate_class = params[:rate_class].constantize
    rate = rate_class.where(:frequency => params[:frequency])
    @user = User.new(params[:user].merge(:time_zone => Time.zone.name, :rate_id => rate.id))
    if @user.save
      for project_email in ProjectEmail.find(:all, :conditions => ["lower(email) = :email",{:email => @user.email.downcase}])
        project_email.convert_to_sharer
      end
      @user_session = UserSession.new(:email => @user.email, :password => params[:user][:password])
      @user_session.save
      redirect_back_or_default dashboard_url
    else
      respond_with(@user) do |format|
        format.mobile { render @render_type => 'new' and return }
        format.html {render @render_type => 'new' and return}
      end
    end
  end
  
  def show
    @user = User.find(params[:id])
    @item = @user
    return if handle_attribute_partials('show')
    @projects_shared_to = @this_user.projects.active.joins(:project_sharers).where("project_sharers.user_id = :user_id",{:user_id => @user.id})
    @projects_shared_from = @user.projects.active.joins(:project_sharers).where("project_sharers.user_id = :user_id",{:user_id => @this_user.id})
    respond_with(@user) do |format|
      format.mobile { render @render_type => 'show'}
      format.html {render :action => 'show' and return}
    end
  end

  def show_full
    @user = User.find(params[:id])
    @projects_shared_to = @this_user.projects.active.joins(:project_sharers).where("project_sharers.user_id = :user_id",{:user_id => @user.id})
    @projects_shared_from = @user.projects.active.joins(:project_sharers).where("project_sharers.user_id = :user_id",{:user_id => @this_user.id})
    if @render_type == :partial
      respond_with(@user) do |format|
        format.any {render @render_type => 'show_full' and return}
      end
    else
      respond_with(@user) do |format|
        format.any {render @render_type => 'show' and return}
      end
    end
  end
  
  def account
    @user = @this_user
    @item = @user
    return if handle_attribute_partials('show')
    respond_with(@user)
  end

  def settings
    @user = @this_user
    respond_with(@user)
  end
  
  def edit
    if params[:reset_password]
      load_user_using_perishable_token
      render :template => 'users/reset_password' and return
    else
      require_user
      @user = @this_user
      @item = @user
      return if handle_attribute_partials('edit')
    end
  end
  
  def update
    if params[:reset_password]
      load_user_using_perishable_token
    else
      require_user
      @user = @this_user # makes our views "cleaner" and more consistent
      @item = @user
    end
    
    if params[:reset_password]
      @user.password = params[:user][:password]  
      @user.password_confirmation = params[:user][:password_confirmation]  
      if @user.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to root_url
      else  
      render :action => :edit  
      end
    else
      if params[:attribute]
        success = false
        if params[:sms_code]
          success = true
          if @user.sms_code == params[:sms_code]
            @user.sms_valid = true
            unless @user.save
              @sms_verification_failed = true
            end
          end
        else
          @user.attributes = params[:user]
          @send_sms_verification = @user.sms_number_changed? ? true : false
          if @user.save
            success = true
            @user.send_sms_verification if @send_sms_verification
          end
        end
        if success
          respond_with(@user) do |format|
            format.any {render :partial => 'show_' + params[:attribute], :layout => 'ajax_section' and return}
          end
        else
          respond_with(@user) do |format|
            format.any {render :partial => 'edit_' + params[:attribute], :layout => 'ajax_section' and return}
          end
        end
      else
        redirect_to account_user_url(@this_user)
      end
    end
  end
  
  def forgot_password
    @user = User.new
  end

  def request_password_reset
    @user = User.find_by_email(params[:user][:email])
    @user.prepare_password_reset
    flash[:notice] = "We sent password reset instructions to your email address."
    redirect_to root_url and return
  end
  
  def activate
    if params[:validate_account]
      load_user_using_perishable_token
      @user.validate_account
      flash[:notice] = "We validated your account, welcome!"
      redirect_to root_url
    else
      redirect_to root_url
    end
  end
  
  def handle_title
    @page_title = 'Account'
    @html_page_title = 'Account'
  end
  
  private
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
    flash[:notice] = "We're sorry, but we could not locate your account. " +  
    "If you are having issues try copying and pasting the URL " +  
    "from your email into your browser or restarting the " +  
    "reset password process."  
    redirect_to root_url  
    end  
  end
end
