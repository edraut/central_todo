class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  scope :by_date, order('updated_at')
  scope :recent, order('created_at desc')
  scope :two, limit(2)
end