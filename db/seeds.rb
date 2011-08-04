# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
home_page = Page.create({ :name => 'Home', :template => 'main', :description => "Get Go helps you organize life. You can share task lists with anyone, access task lists from most devices, and it's super simple to use. Collaborate with friends and colleagues to get things done."})
features_page = Page.create({ :name => 'Features', :template => 'features', :description => "Get Go has everything you need to organize your task lists and nothing else. Super simple."})
pricing_page = Page.create({ :name => 'Pricing', :template => 'pricing', :description => "Get Go has a plan for you. From the Basic plan for individuals and freelancers to the Unlimited plan for larger organizations, we've got you covered."})
support_page = Page.create({ :name => 'Support', :template => 'support', :description => "Get Go keeps you going by offering tools that are easy to understand with helpful tips in context. For those rare occasions when you need more support, we have an FAQ that answers the most common questions, and you can always contact us for more support."})
support_page = Page.create({ :name => 'Terms of Service', :template => 'terms', :description => "Get Go Terms of Service"})
support_page = Page.create({ :name => 'Privacy Policy', :template => 'privacy', :description => "Get Go Privacy Policy"})
contact_page = Page.create({ :name => 'Contact', :template => 'contact', :description => "Get Go Contact Information"})
tour_page = Page.create({ :name => 'Tour', :template => 'tour', :description => "Check out some screen shots of Get Go in action."})
free = FreeRate.create({:amount => Money.new(0),:frequency => 'never'})
basic_monthly = BasicRate.create({:amount => Money.new(799),:frequency => 'month'})
basic_yearly = BasicRate.create({:amount => Money.new(7999),:frequency => 'year'})
super_monthly = SuperRate.create({:amount => Money.new(1499),:frequency => 'month'})
super_yearly = SuperRate.create({:amount => Money.new(14999),:frequency => 'year'})
unlimited_monthly = UnlimitedRate.create({:amount => Money.new(2999),:frequency => 'month'})
unlimited_yearly = UnlimitedRate.create({:amount => Money.new(29999),:frequency => 'year'})