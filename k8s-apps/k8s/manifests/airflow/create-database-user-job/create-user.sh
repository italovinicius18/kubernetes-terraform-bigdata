#!/bin/bash

execute_sql() {
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" \
         -d "$1" -w \
         -c "$2"
}

user_exists() {
    execute_sql "$DB_ADMIN_NAME" "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1
}

database_exists() {
    execute_sql "$DB_ADMIN_NAME" "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1
}

if ! user_exists; then
    execute_sql "$DB_ADMIN_NAME" "CREATE USER $DB_USER WITH PASSWORD '$DB_USER_PASSWORD';"
    echo "User $DB_USER created successfully."
else
    echo "User $DB_USER already exists. Skipping user creation."
fi

# Create database if it doesn't exist
if ! database_exists; then
    execute_sql "$DB_ADMIN_NAME" "CREATE DATABASE $DB_NAME;"
    echo "Database $DB_NAME created successfully."
else
    echo "Database $DB_NAME already exists. Skipping database creation."
fi

# Grant privileges
execute_sql "$DB_NAME" "GRANT ALL PRIVILEGES ON SCHEMA public TO $DB_USER;"
execute_sql "$DB_NAME" "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
echo "Privileges granted successfully."
