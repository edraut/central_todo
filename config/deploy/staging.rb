role :app, "my-ti.me"
role :web, "my-ti.me"
role :db,  "my-ti.me", :primary => true
role :push, "my-ti.me"

set :db_user, "my_time"
set :db_pass, "D5j35hq9C"

set :branch, "staging"

set :rails_env, "production"
