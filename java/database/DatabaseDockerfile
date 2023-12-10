# Start from the official PostgreSQL image
FROM postgres:12-alpine

# Set the working directory to /docker-entrypoint-initdb.d in the image
WORKDIR /docker-entrypoint-initdb.d

# Copy the SQL files from your host into the image
COPY . /docker-entrypoint-initdb.d

# Remove the dropdb.sql and create.sh files to prevent them from being executed
RUN rm dropdb.sql && \
    rm create.sh

# Rename the SQL files so that they are auto-run in this order on image build
RUN mv schema.sql 01schema.sql && \
    mv data.sql 02data.sql && \
    mv user.sql 03user.sql

# The default command of the postgres:12-alpine image will start the PostgreSQL server