class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders, :force => true do |t|
      t.string :title
      t.integer :user_id
    end
    add_column :projects, :folder_id, :integer
  end

  def self.down
    remove_column :projects, :folder_id
    drop_table :folders
  end
end