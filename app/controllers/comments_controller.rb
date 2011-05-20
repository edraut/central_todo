class CommentsController < ApplicationController
  before_filter :require_user
  before_filter :get_comment, :only => [:show,:edit,:update,:destroy]
  before_filter :handle_broken_browser_methods, :only => [:show, :create, :update]
  before_filter :set_nav_tab
  respond_to :html, :mobile
  
  def index
    @commentable_class = params[:commentable_type].constantize
    @commentable = @commentable_class.find(params[:commentable_id])
    respond_with(@commentable) do |format|
      format.any {render :partial => 'index', :locals => {:commentable => @commentable}}
      return
    end
    redirect_to root_url and return
  end

  def recent
    render @render_type => 'recent' and return
  end
  
  def show
    respond_with(@comment) do |format|
      format.any {render :partial => 'show', :locals => {:comment => @comment, :editable => true}}
    end
  end
  
  def create
    @comment = Comment.new(params[:comment].merge(:user_id => @this_user.id))
    if @comment.save
      respond_with(@comment) do |format|
        format.any {render :partial => 'show', :locals => {:comment => @comment, :editable => true}, :layout => 'new_comment'}
      end
    else
      respond_with(@comment) do |format|
        format.any {render :partial => 'new', :locals => {:comment => @comment}}
      end
    end
  end
  
  def edit
    respond_with(@comment) do |format|
      format.any {render :partial => 'edit', :locals => {:comment => @comment}, :layout => 'ajax_line_item'}
    end
  end
  
  def update
    unless @comment.commentable.all_users.include? @this_user
      flash[:notice] = "You don't have privileges to access that comment."
      redirect_to root_url and return
    end
    if @comment.update_attributes(params[:comment])
      respond_with(@comment) do |format|
        format.any {render :partial => 'show', :locals => {:comment => @comment, :editable => true}}
      end
    else
      respond_with(@comment) do |format|
        format.any {render :partial => 'edit', :locals => {:comment => @comment}}
      end
    end
  end
  
  def destroy
    @comment.destroy
    render :nothing => true and return
  end

  def get_comment
    @comment = Comment.find(params[:id])
    @item = @comment
    if @comment.commentable.user_id != @this_user.id and !@comment.commentable.all_users.include? @this_user
      flash[:notice] = "You don't have privileges to access that comment."
      redirect_to root_url and return
    end
  end
end