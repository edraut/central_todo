class RemoveTimes < ActiveRecord::Migration
  def self.up
    change_column :tasks, :due_date, :date
    change_column :projects, :due_date, :date
  end

  def self.down
    change_column :projects, :due_date, :datetime
    change_column :tasks, :due_date, :datetime
  end
end