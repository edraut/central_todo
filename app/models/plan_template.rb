class PlanTemplate < ActiveRecord::Base
  has_many :task_templates
  has_many :project_sharer_templates
  belongs_to :user
  
  def generate_plan
    project = Project.create(Hash[self.attributes.select{|a,v| ['title','description','user_id','type'].include? a}])
    for task_template in self.task_templates
      task = Task.create(Hash[task_template.attributes.select{|a,v| ['title','description','user_id','type','position'].include? a}].merge(:project_id => project.id))
    end
    for project_sharer_template in self.project_sharer_templates
      project_sharer = ProjectSharer.create(Hash[project_sharer_template.attributes.select{|a,v| ['user_id'].include? a}].merge(:project_id => project.id))
    end
    return project
  end
end