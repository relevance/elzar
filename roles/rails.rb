name        "rails"
description "rails application and web server"
override_attributes(:mysql => {
                      :server_root_password => "" })
run_list( 'nginx', 'mysql', 'mysql::server')
