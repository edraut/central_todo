class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :projects, :dependent => :destroy
  has_many :project_sharers
  has_many :shared_projects, :through => :project_sharers
  scope :ordered, order(:position)
end