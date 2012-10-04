TemplateRoot = File.expand_path '..', __FILE__

gem 'capistrano', :group => 'deployment', :git => 'git://github.com/capistrano/capistrano', :ref => 'b31e2f5'
gem 'capistrano-relevance', :group => 'deployment'

gem 'therubyracer', :group => 'assets', :platforms => :ruby

run 'bundle install'
run 'bundle exec capify .'

remove_file File.join('config', 'deploy.rb')
copy_file File.join(TemplateRoot, 'deploy.rb'), File.join('config', 'deploy.rb')

run 'rails generate scaffold user username:string'

next_migration_timestamp = (Time.now + 1)
migration_filename = next_migration_timestamp.utc.strftime("%Y%m%d%H%M%S") + '_add_root_user.rb'
copy_file File.join(TemplateRoot, 'add_root_user.rb'), File.join('db', 'migrate', migration_filename)

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"
