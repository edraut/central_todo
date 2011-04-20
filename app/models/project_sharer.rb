class ProjectSharer < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :folder
  
  scope :active, joins(:project).where("projects.state = 'active'")

  validates_uniqueness_of :user_id, :scope => :project_id
end