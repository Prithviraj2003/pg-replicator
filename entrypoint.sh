#!/bin/bash
set -e

# Start PostgreSQL in the background
echo "Starting PostgreSQL..."
docker-entrypoint.sh postgres -c config_file=/etc/postgresql/postgresql.conf -c hba_file=/etc/postgresql/pg_hba.conf &

# Wait for PostgreSQL to start
until pg_isready -h $REPLICA_HOST -p $REPLICA_PORT; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

SUFFIX=1
PUBLICATION_NAME="pub"
echo "PostgreSQL started."

# Check if the replication exists on the replica
echo "Checking if replication exists on the replica..."
if [ "$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $REPLICA_HOST -p $REPLICA_PORT -U $POSTGRES_USER -d $POSTGRES_DB -tAc "SELECT 1 FROM pg_stat_subscription WHERE subname='subscription'")" = "1" ]; then
  echo "Replication already exists on the replica."
  tail -f /dev/null
fi
# Run pg_dump to replicate the database schema
echo "Running pg_dump..."
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h $REPLICATOR_HOST -p $REPLICATOR_PORT -U $POSTGRES_USER -d $POSTGRES_DB -s | PGPASSWORD=$POSTGRES_PASSWORD psql -h $REPLICA_HOST -p $REPLICA_PORT -U $POSTGRES_USER -d $POSTGRES_DB

# Function to check if the publication exists
check_publication_exists() {
  PGPASSWORD=$POSTGRES_PASSWORD psql -h $REPLICATOR_HOST -p $REPLICATOR_PORT -U $POSTGRES_USER -d $POSTGRES_DB -tAc "SELECT 1 FROM pg_publication WHERE pubname='$PUBLICATION_NAME'"
}

# Generate a unique publication name if needed
while [ "$(check_publication_exists)" = "1" ]; do
  PUBLICATION_NAME="pub_${SUFFIX}"
  SUFFIX=$((SUFFIX + 1))
  echo "Publication name already exists. Trying '$PUBLICATION_NAME'..."
done

# Create the publication with the unique name
PGPASSWORD=$POSTGRES_PASSWORD psql -h $REPLICATOR_HOST -p $REPLICATOR_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "CREATE PUBLICATION $PUBLICATION_NAME FOR $TABLE_NAME;"


echo "Publication '$PUBLICATION_NAME' created."

# Create the subscription with the unique name
PGPASSWORD=$POSTGRES_PASSWORD psql -h $REPLICA_HOST -p $REPLICA_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "CREATE SUBSCRIPTION subscription CONNECTION 'dbname=$POSTGRES_DB host=$REPLICATOR_HOST port=$REPLICATOR_PORT user=$POSTGRES_USER password=$POSTGRES_PASSWORD' PUBLICATION $PUBLICATION_NAME;"

echo "Subscription sub created."

# Keep the container running
tail -f /dev/null
