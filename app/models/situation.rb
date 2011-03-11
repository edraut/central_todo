class Situation < ActiveRecord::Base
  has_many :task_situations, :dependent => :destroy
  has_many :tasks, :through => :task_situations
  belongs_to :user
  validates_presence_of :title
  
  scope :for_user, lambda{ |user| {:conditions => {:user_id => user.id}}}
end
