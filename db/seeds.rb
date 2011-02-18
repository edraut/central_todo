# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
home_page = Page.create({ :name => 'Home', :template => 'main', :description => "This is your to-do list. It's always there, and you can look at it from the angle that help most in the moment. "})
