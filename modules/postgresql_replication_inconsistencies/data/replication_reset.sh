

#!/bin/bash



# Assuming the following variables are already set:

# - ${PRIMARY_DB_HOST} : hostname or IP address of the primary database

# - ${REPLICA_DB_HOST} : hostname or IP address of the replica database

# - ${PG_REWIND_PATH} : path to the pg_rewind binary on the replica server



# Stop replication on the replica server

ssh ${REPLICA_DB_HOST} "pg_ctl stop -D ${POSTGRES_DATA_DIRECTORY} -m fast"



# Run pg_rewind on the replica server to reset it to match the primary database

ssh ${REPLICA_DB_HOST} "${PG_REWIND_PATH} --target-pgdata=${POSTGRES_DATA_DIRECTORY} --source-server='host=${PRIMARY_DB_HOST} user=${REPLICATION_USER}'"



# Start the replica server

ssh ${REPLICA_DB_HOST} "pg_ctl start -D ${POSTGRES_DATA_DIRECTORY}"



# Check replication status to ensure consistency has been restored