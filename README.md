# Repository Overview for `pg-replicator`

## pg-replicator: Simplifying PostgreSQL Database Replication

pg-replicator is a versatile Docker image designed to streamline PostgreSQL database replication. It supports two main use cases: replicating data from a host database to a user-specified database, and acting as a standalone database replica that users can access directly.

### Key Features

- **Automated Replication**: Easily replicate PostgreSQL databases from a host to a replica with minimal configuration.
- **Flexible Configuration**: Customize the replication process using environment variables.
- **Persistent Data Storage**: Use Docker volumes to ensure your data is stored persistently.
- **Monitoring and Logging**: Continuous monitoring of the replication process with logging for status tracking.

### Use Cases

1. **As a Replicator**:
   - **Description**: Replicate the database from a host database to a user-specified database.
   - **Command**:
     ```sh
     docker run -d -p 5432:5432 -v pgdata:/var/lib/postgresql/data
       -e POSTGRES_USER=myuser
       -e POSTGRES_PASSWORD=mypassword
       -e POSTGRES_DB=mydb
       -e REPLICA_HOST=replica_host_ip 
       -e REPLICA_PORT=replica_host_port 
       -e REPLICATOR_HOST=replicator_host_ip
       -e REPLICATOR_PORT=replicator_host_port
       -e TABLE_NAME="ALL TABLES"
       --name my_postgres_container
       pg-replicator
     ```

2. **As a Database Replica**:
   - **Description**: Use the image as a standalone database replica, which can be accessed via the exposed port.
   - **Command**:
     ```sh
     docker run -d -p 5432:5432 -v pgdata:/var/lib/postgresql/data 
       -e POSTGRES_USER=myuser 
       -e POSTGRES_PASSWORD=mypassword 
       -e POSTGRES_DB=mydb 
       -e REPLICATOR_HOST=replicator_host_ip 
       -e REPLICATOR_PORT=replicator_host_port  
       --name my_postgres_container
       pg-replicator
     ```

## Getting Started

### Prerequisites

- Replica database should be `wal_level=logical` 

### Creating a Docker Volume

Before running the container, create a Docker volume to persist your PostgreSQL data:

```sh
docker volume create pgdata
```

## Environment Variables

- `POSTGRES_USER`: The PostgreSQL user 
- `POSTGRES_PASSWORD`: The PostgreSQL password 
- `POSTGRES_DB`: The PostgreSQL database name 
- `REPLICA_HOST`: The hostname of the replica (Default: localhost , Required for replicator use case)
- `REPLICA_PORT`: The port number of the replica (Default: 5432, Required for replicator use case)
- `REPLICATOR_HOST`: The hostname of the replicator
- `REPLICATOR_PORT`: The port number of the replicator
- `TABLE_NAME`: The table name to replicate (Default: ALL TABLES , Example: TABLES table_1,table_2)

## Entrypoint Script

The custom entrypoint script handles the following:

- Starting PostgreSQL in the background
- Waiting for the replica to be ready
- Checking for existing replication
- Running pg_dump to replicate the database schema
- Creating publication and subscription for replication

## Contributing
We welcome contributions to improve `pg-replicator`. Feel free to open issues and pull requests on our GitHub repository.
  
___
  
Simplify your PostgreSQL replication setup with `pg-replicator` and ensure consistent data availability across your infrastructure.