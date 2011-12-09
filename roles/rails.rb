name        "rails"
description "rails application and web server"
override_attributes(:mysql => {
                      :server_root_password => "" },
                    :nginx => {
                      :version => "1.0.10"})
run_list(
         'apt',
         'curl',
         'mysql::server',
         'ruby_enterprise',
         'passenger_enterprise::nginx'
         )
