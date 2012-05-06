name        "postgres_database"
description "install postgres and configure it to allow access to the rails user"

run_list('postgresql::server')
