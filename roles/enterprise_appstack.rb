name        "enterprise_appstack"
description "stack for ree"

run_list('ruby_enterprise', 'passenger_enterprise::nginx')
