class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.datetime :due_date
      t.text :description
      t.string :type
      t.integer :user_id
      t.integer :position
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
