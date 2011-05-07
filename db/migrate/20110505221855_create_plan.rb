class CreatePlan < ActiveRecord::Migration
  def self.up
    create_table :rates, :force => true do |t|
      t.integer :amount
      t.string  :frequency
      t.string  :type
    end
    add_column :users, :billing_date, :date
    add_column :users, :rate_id, :integer
    User.reset_column_information
    User.all.each do |user|
      user.rate_id = 1
      user.save
    end
    class Rate < ActiveRecord::Base
    end
    class BasicRate < Rate
    end
    class SuperRate < Rate
    end
    class UnlimitedRate < Rate
    end
    features_page = Page.create({ :name => 'Features', :template => 'features', :description => "Get Go has everything you need to organize your task lists and nothing else. Super simple."})
    pricing_page = Page.create({ :name => 'Pricing', :template => 'pricing', :description => "Get Go has a plan for you. From the Basic plan for individuals and freelancers to the Unlimited plan for larger organizations, we've got you covered."})
    support_page = Page.create({ :name => 'Support', :template => 'support', :description => "Get Go keeps you going by offering tools that are easy to understand with helpful tips in context. For those rare occasions when you need more support, we have an FAQ that answers the most common questions, and you can always contact us for more support."})
    basic_monthly = BasicRate.create({:amount => 799,:frequency => 'month'})
    basic_yearly = BasicRate.create({:amount => 7999,:frequency => 'year'})
    super_monthly = SuperRate.create({:amount => 1499,:frequency => 'month'})
    super_yearly = SuperRate.create({:amount => 14999,:frequency => 'year'})
    unlimited_monthly = UnlimitedRate.create({:amount => 2999,:frequency => 'month'})
    unlimited_yearly = UnlimitedRate.create({:amount => 29999,:frequency => 'year'})  end

  def self.down
    remove_column :users, :rate_id
    remove_column :users, :billing_date
    drop_table :rates
  end
end