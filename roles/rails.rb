name        "rails"
description "rails application and web server"

passenger_version = "3.0.11"

override_attributes(:mysql => {
                      :server_root_password => "" },
                    :nginx => {
                      :version => "1.0.10"},
                    :passenger_enterprise => {
                      :version => passenger_version,
                      :root_path => "/opt/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{passenger_version}",
                      :module_path => "/opt/ruby-enterprise/lib/ruby/gems/1.8/gems/passenger-#{passenger_version}/ext/apache2/mod_passenger.so"
                    },
                    :ruby_enterprise => {
                      :version => '1.8.7-2012.02',
                      :url => "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2012.02"
                    })
run_list(
         'apt',
         'curl',
         'mysql::server',
         'nginx::source',
         'ruby_enterprise',
         'passenger_enterprise::nginx',
         'rails_app'
         )
