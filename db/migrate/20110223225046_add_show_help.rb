class AddShowHelp < ActiveRecord::Migration
  def self.up
    add_column :users, :show_help_text, :boolean, :default => true
    User.reset_column_information
    User.update_all :show_help_text => true
  end

  def self.down
    remove_column :users, :show_help_text
  end
end