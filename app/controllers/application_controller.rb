class ApplicationController < ActionController::Base
  protect_from_forgery
  has_mobile_fu
  helper_method :current_user_session, :current_user
  before_filter :get_method
  before_filter :handle_xhr
  before_filter :handle_layout
  before_filter :handle_title
  before_filter :init_ajax_forms
  before_filter :get_this_user
  after_filter :handle_flash_header

  def string_to_money(string)
    Money.new(string.to_f * 100)
  end
  
  def manage_money
    for money_attribute in @money_attributes
      @editable_params[money_attribute] = string_to_money(@editable_params[money_attribute])
    end
  end

  def handle_attribute_partials(action)
    if params[:attribute]
      respond_with(@item) do |format|
        format.any {render :partial => action + '_' + params[:attribute], :layout => 'ajax_section' and return true}
      end
      return false
    end
    return false
  end
  
  def handle_broken_browser_methods
    if params[:_method]
      case params[:_method].downcase
      when 'put'
        update and return
      when 'delete'
        destroy and return
      end
    end
  end

  def handle_flash_header
    flash.discard
  end
  
  def handle_xhr
    if request.xhr?
      @render_type = :partial
    else
      @render_type = :action
    end
  end
  
  def handle_layout
    @this_layout = true
    if request.xhr?
      if is_mobile_device?
        @this_layout = 'application'
      else
        @this_layout = false
      end
    end
  end
  
  def handle_title
    @page_title = controller_name.humanize
    @html_page_title = controller_name.humanize
  end
  
  def init_ajax_forms
    @ajax_forms_enabled = false
  end
  
  private
    def get_method
      if params.has_key? '_method'
        @this_method = params['_method'].downcase
      else
        @this_method = request.method.downcase
      end
    end
    def get_this_user
      if !request.xhr? and !(['delete','put','post'].include? @this_method) and controller_name != 'user_sessions'
        store_location
      end
      @this_user = current_user
      Time.zone = @this_user.time_zone if @this_user
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
      Time.zone = ActiveSupport::TimeZone[-session[:time_zone_offset].to_i]
      return @current_user_session
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    def require_user 
      unless current_user 
        if !request.xhr? and !(['delete','put','post'].include? @this_method) and controller_name != 'user_sessions'
          store_location
        end
        flash[:notice] = "You must be logged in to access this page" 
        redirect_to sign_in_url 
        return false 
      end
      return true
    end
    def require_admin
      if require_user
        if current_user.class.name != 'Admin'
          flash[:notice] = "You don't have the right privileges to view that page."
          redirect_to root_url
          return false
        else
          return true
        end
      else
        return false
      end
    end
    
    def require_no_user 
      if current_user 
        if !request.xhr? and !(['delete','put','post'].include? @this_method) and controller_name != 'user_sessions'
          store_location
        end
        flash[:notice] = "You must be logged out to access this page" 
        redirect_to root_url 
        return false 
      end 
    end 
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
