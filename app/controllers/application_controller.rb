class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user
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
      render :partial => action + '_' + params[:attribute], :layout => 'ajax_section' and return
    end
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
  private
    def get_this_user
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
        store_location 
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
        store_location 
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
