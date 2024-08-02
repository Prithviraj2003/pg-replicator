# Use the official PostgreSQL image from the Docker Hub
FROM postgres:16

# Set default arguments
ARG REPLICA_HOST=localhost
ARG REPLICA_PORT=5432
ARG TABLE_NAME="ALL TABLES"

# Set environment variables
ENV REPLICA_HOST=${REPLICA_HOST}
ENV REPLICA_PORT=${REPLICA_PORT}
ENV TABLE_NAME=${TABLE_NAME}




# Copy custom configuration files
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Create the data directory and set permissions
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5432
# Use the custom entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
