name        "rails"
description "rails application and web server"
override_attributes(:mysql => {
                      :server_root_password => "" })
run_list(
         'curl',
         'mysql::server',
         'ruby_enterprise',
         'passenger_enterprise::nginx'
         )
