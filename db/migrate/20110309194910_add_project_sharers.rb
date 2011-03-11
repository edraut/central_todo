class AddProjectSharers < ActiveRecord::Migration
  def self.up
    create_table :project_sharers, :force => true do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :project_sharers
  end
end