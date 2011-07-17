class HeadsUp < ActiveRecord::Base
  belongs_to :alertable, :polymorphic => true
  belongs_to :user
end