class Rate < ActiveRecord::Base
  has_many :users
  composed_of :amount, :class_name => 'Money', :mapping => [%w(amount cents)]
  
  def self.frequencies
    [
      {:name => 'month', :display => 'Monthly'},
      {:name => 'year', :display => 'Yearly'},
    ]
  end
  
  def frequency_display
    case self.frequency
    when 'month'
      'Monthly'
    when 'year'
      'Yearly'
    end
  end
end