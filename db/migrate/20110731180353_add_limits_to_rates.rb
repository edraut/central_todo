class AddLimitsToRates < ActiveRecord::Migration
  def self.up
    add_column :rates, :project_limit, :integer
  end

  def self.down
    remove_column :rates, :project_limit
  end
end