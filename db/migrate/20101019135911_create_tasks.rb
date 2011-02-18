class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title
      t.integer :project_id
      t.integer :situation_id
      t.boolean :complete, :default => :false, :null => :false
      t.boolean :retired, :default => :false, :null => :false
      t.datetime :due_date
      t.text :description
      t.string :type
      t.integer :user_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
