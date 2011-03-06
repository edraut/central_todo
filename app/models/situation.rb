class Situation < ActiveRecord::Base
  has_many :tasks, :dependent => :nullify
  belongs_to :user
  validates_presence_of :title
end
