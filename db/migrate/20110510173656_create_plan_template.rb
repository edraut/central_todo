class CreatePlanTemplate < ActiveRecord::Migration
  def self.up
    create_table :plan_templates, :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.integer  "user_id"
      t.string   "type"
      t.timestamps
    end
    create_table :task_templates, :force => true do |t|
      t.string   "title"
      t.integer  "plan_template_id"
      t.integer  "user_id"
      t.text     "description"
      t.string   "type"
      t.integer  "position"
    end
    create_table :project_sharer_templates, :force => true do |t|
      t.integer :plan_template_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_sharer_templates
    drop_table :task_templates
    drop_table :plan_templates
  end
end