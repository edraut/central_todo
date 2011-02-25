class PagesController < ApplicationController
  before_filter :get_page
  respond_to :html, :mobile
  def show
    (redirect_to dashboard_url and return) if @page.name == 'Home' and current_user
    @html_page_title = @page.name
    respond_with(@page) do |format| 
      format.html {render :template => '/pages/' + @page.template}
      format.mobile {render :template => '/pages/mobile/' + @page.template}
    end
  end
  
  def get_page
    @page = Page.find(params[:id])
  end
end