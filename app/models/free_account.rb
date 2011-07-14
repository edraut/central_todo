class FreeAccount < User
  
  def create_first_folder
    folder = Folder.create(:user_id => self.id, :title => 'All Plans')
  end
  
  def handle_validity
    self.activate_account
  end
end