class Situation < ActiveRecord::Base
  has_many :tasks, :dependent => :nullify
  belongs_to :user
end
