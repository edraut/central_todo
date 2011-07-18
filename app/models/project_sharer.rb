class ProjectSharer < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :folder
  after_create :handle_heads_ups
  after_destroy :transfer_tasks_to_owner
  
  scope :active, joins(:project).where("projects.state = 'active'")

  validates_uniqueness_of :user_id, :scope => :project_id
  def handle_heads_ups
    heads_up = HeadsUp.where(:user_id => self.user_id,:alertable_id => self.project.id,:alertable_type => 'Project').first
    heads_up ||= HeadsUp.create(:user_id => self.user_id,:alertable_id => self.project.id,:alertable_type => 'Project')
    owner_heads_up = HeadsUp.where(:user_id => self.project.user_id,:alertable_id => self.project.id,:alertable_type => 'Project').first
    owner_heads_up ||= HeadsUp.create(:user_id => self.project.user_id,:alertable_id => self.project.id,:alertable_type => 'Project')
  end
  
  def transfer_tasks_to_owner
    Task.update_all "user_id = #{self.project.user_id}" , "user_id = #{self.user_id} AND project_id = #{self.project_id}"
  end
end