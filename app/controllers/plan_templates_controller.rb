class PlanTemplatesController < ApplicationController
  before_filter :get_plan_template, :only => [:update,:destroy]
  before_filter :set_nav_tab

  def index
    @plan_templates = @this_user.plan_templates
  end
  
  def update
    @plan_template.update_attributes(params[:plan_template])
    render :partial => 'show', :locals => {:plan_template => @plan_template}
  end
  
  def destroy
    @plan_template.destroy
    render :nothing => true and return
  end
  
  def get_plan_template
    @plan_template = PlanTemplate.find(params[:id].to_i)
  end
end