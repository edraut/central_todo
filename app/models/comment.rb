class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  scope :by_date, order('updated_at')
  scope :recent, order('comments.created_at desc').where("comments.created_at > (current_date at time zone 'UTC' - interval '2 week')")
  scope :two, limit(2)
  
  after_create :handle_alerts
  
  def handle_alerts
    alertees = self.commentable.heads_ups.where("heads_ups.user_id != #{self.user_id}")
    alertees.each do |alertee|
      Notifier.comment_alert(alertee.user,self).deliver
    end
  end
end