
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# PostgreSQL Replication Inconsistencies
---

PostgreSQL Replication Inconsistencies refer to a situation where the replicas of the primary database are not properly synchronized, leading to discrepancies in the data that they contain. This can cause data consistency issues and make it difficult to troubleshoot and resolve the underlying problem. Identifying the root cause of replication inconsistencies is essential to ensure that the data across all databases is consistent and accurate.

### Parameters
```shell
export VERSION="PLACEHOLDER"

export REPLICA_DB_ADDRESS="PLACEHOLDER"

export PRIMARY_DB_ADDRESS="PLACEHOLDER"

export POSTGRES_DATA_DIRECTORY="PLACEHOLDER"

export REPLICATION_USER="PLACEHOLDER"

export REPLICA_DB_HOST="PLACEHOLDER"

export PG_REWIND_PATH="PLACEHOLDER"

export PRIMARY_DB_HOST="PLACEHOLDER"
```

## Debug

### 1. Check the status of the PostgreSQL service
```shell
systemctl status postgresql
```

### 2. Verify that replication is set up correctly
```shell
sudo -u postgres psql -c "select * from pg_stat_replication;"
```

### 3. Check the replication lag between the primary and replica databases
```shell
sudo -u postgres psql -c "select pg_last_xact_replay_timestamp() - pg_last_xact_commit_timestamp() AS replication_lag_bytes;"
```

### 4. Verify that the replica is receiving updates from the primary
```shell
sudo -u postgres psql -c "select pg_last_xlog_receive_location() AS receive, pg_last_xlog_replay_location() AS replay;"
```

### 5. Check the replication status of the replica
```shell
sudo -u postgres psql -c "select * from pg_stat_wal_receiver;"
```

### 6. Check the logs for any errors or warnings related to replication
```shell
tail -f /var/log/postgresql/postgresql-${VERSION}-main.log
```

### Network latency or connectivity issues between the primary database and its replicas can cause replication delays, leading to inconsistencies in the data.
```shell


#!/bin/bash



PRIMARY_DB=${PRIMARY_DB_ADDRESS}

REPLICA_DB=${REPLICA_DB_ADDRESS}



ping -c 3 $PRIMARY_DB > /dev/null

if [ $? -eq 0 ]; then

  echo "Primary database is reachable"

else

  echo "Primary database is unreachable"

fi



ping -c 3 $REPLICA_DB > /dev/null

if [ $? -eq 0 ]; then

  echo "Replica database is reachable"

else

  echo "Replica database is unreachable"

fi



ping -c 3 $PRIMARY_DB > /dev/null && ping -c 3 $REPLICA_DB > /dev/null

if [ $? -eq 0 ]; then

  echo "Network connectivity seems fine"

else

  echo "Network connectivity issues detected"

fi


```

## Repair

### If replication inconsistencies persist, consider using a tool like pg_rewind to reset the replicas to match the primary database. This can be a more efficient way to reset the replicas than rebuilding them from scratch.
```shell


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


```