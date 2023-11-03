

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