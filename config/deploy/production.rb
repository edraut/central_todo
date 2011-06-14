role :app, "66.228.56.101"
role :web, "66.228.56.101"
role :db,  "66.228.56.101", :primary => true
role :push, "66.228.56.101"

set :db_user, "getgo"
set :db_pass, "D5j35hq9C"

set :branch, "production"

set :rails_env, "production"
