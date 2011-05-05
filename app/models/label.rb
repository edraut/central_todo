class Label < ActiveRecord::Base
  has_many :task_labels, :dependent => :destroy
  has_many :tasks, :through => :task_labels
  belongs_to :user
  validates_presence_of :title
  before_create :default_color
  
  scope :for_user, lambda{ |user| {:conditions => {:user_id => user.id}}}

  def default_color
    self.color = Label::COLORS[rand(Label::COLORS.length)]
  end
  
  COLORS = [
    "Red_Orange",
    "Lemon_Pie",
    "Grass",
    "Pacific_Blue",
    "Indigo",
    "Wisteria",
    "Cotton_Candy",
    "White",
    "Gray",
    "Black"
  ]
end
