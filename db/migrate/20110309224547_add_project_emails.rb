class AddProjectEmails < ActiveRecord::Migration
  def self.up
    create_table :project_emails, :force => true do |t|
      t.integer :project_id
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :project_emails
  end
end