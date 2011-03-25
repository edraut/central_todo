role :app, "getgolist.com"
role :web, "getgolist.com"
role :db,  "getgolist.com", :primary => true
role :push, "getgolist.com"

set :db_user, "my_time"
set :db_pass, "D5j35hq9C"

set :branch, "staging"

set :rails_env, "production"
