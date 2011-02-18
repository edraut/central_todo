class PagesController < ApplicationController
  before_filter :get_page
  def show
    (redirect_to dashboard_url and return) if @page.name == 'Home' and current_user
    @html_page_title = @page.name
    render :template => '/pages/' + @page.template
  end
  
  def get_page
    @page = Page.find(params[:id])
  end
end