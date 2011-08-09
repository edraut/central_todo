class Folder < ActiveRecord::Base
  belongs_to :user
  has_many :projects, :dependent => :destroy
  has_many :project_sharers
  has_many :shared_projects, :through => :project_sharers
  scope :ordered, order(:position)
  scope :active, where("folders.state = 'active'")
  scope :archived, where("folders.state = 'archived'")
  #special behaviors

  state_machine :initial => :active, :action => nil do
    after_transition :on => :archive, :do => :archive_plans
    after_transition :on => :activate, :do => :unarchive_plans
    state :active
    state :archived
    event :activate do
      transition all => :active
    end
    event :archive do
      transition :active => :archived
    end
  end

  def handle_attributes(new_attributes)
    new_state = new_attributes.delete(:state)
    self.attributes = (new_attributes)
    if new_state == self.state
      return false
    else
      case new_state
      when 'archived'
        self.archive
        Rails.logger.info("%%%%%%%%%%%finished handling attributes #{self.state}")
      when 'active'
        self.activate
        Rails.logger.info("%%%%%%%%%%%finished handling attributes #{self.state}")
      end
      return true
    end
    
  end
  
  def archive_plans
    Rails.logger.info("%%%%%%%% archiving plans #{caller.inspect}")
    self.projects.each do |plan|
      if self.user_id == plan.user_id
        plan.archive
        res = plan.save
      end
    end
    return true
  end

  def unarchive_plans
    Rails.logger.info("%%%%%%%% unarchiving plans #{caller.inspect}")
    self.projects.each do |plan|
      if self.user_id == plan.user_id
        plan.activate
        res = plan.save
      end
    end
    return true
  end
  
end