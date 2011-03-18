class AddColor < ActiveRecord::Migration
  def self.up
    add_column :labels, :color, :string
  end

  def self.down
    remove_column :labels, :color
  end
end