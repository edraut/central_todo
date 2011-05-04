class FreeAccount < User
  after_create :create_first_folder
  
  def create_first_folder
    folder = Folder.create(:user_id => self.id, :title => 'All Plans')
  end
end