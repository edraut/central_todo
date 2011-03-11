class ProjectEmail < ActiveRecord::Base
  belongs_to :project
  
  def convert_to_sharer
    user = User.find(:first, :conditions => ["lower(email) = :sharer_email",{:sharer_email => self.email.downcase}])
    if user
      if ProjectSharer.create(:project_id => self.project_id,:user_id => user.id)
        self.destroy
      else
        return false
      end
    else
      return false
    end
  end
end