name        "plumbing"
description "plumbing for elzar"

override_attributes(:nginx => {
                      :version => "1.0.10"
                    })
run_list(
         'apt',
         'curl',
         'nginx::source'
         )
