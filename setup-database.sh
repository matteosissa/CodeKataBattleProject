#!/bin/bash
# Setup script for existing PostgreSQL

echo "Setting up Code Kata Battle database..."
echo "======================================="

# Check if PostgreSQL is running
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "Error: PostgreSQL is not running on localhost:5432"
    exit 1
fi

echo "PostgreSQL is running ✓"

# Ask for postgres password
echo ""
echo "Enter PostgreSQL superuser password (press Enter if no password):"
read -s PG_PASSWORD

# Create database if it doesn't exist
echo ""
echo "Creating database 'ckb'..."
if [ -z "$PG_PASSWORD" ]; then
    psql -h localhost -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'ckb'" | grep -q 1 || psql -h localhost -U postgres -c "CREATE DATABASE ckb;"
else
    PGPASSWORD="$PG_PASSWORD" psql -h localhost -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'ckb'" | grep -q 1 || PGPASSWORD="$PG_PASSWORD" psql -h localhost -U postgres -c "CREATE DATABASE ckb;"
fi

echo "Database created ✓"

# Run SQL scripts if they exist
SQL_SCRIPT="codekatabattle-source/score_computation_microservice/sql_sonarqube/script_sonarqube.sql"
if [ -f "$SQL_SCRIPT" ]; then
    echo ""
    echo "Running SQL initialization scripts..."
    if [ -z "$PG_PASSWORD" ]; then
        psql -h localhost -U postgres -d ckb -f "$SQL_SCRIPT"
    else
        PGPASSWORD="$PG_PASSWORD" psql -h localhost -U postgres -d ckb -f "$SQL_SCRIPT"
    fi
    echo "SQL scripts executed ✓"
fi

echo ""
echo "Database setup complete!"
echo ""
echo "Database credentials:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: ckb"
echo "  Username: postgres"
echo "  Password: (your postgres password)"
echo ""
echo "Note: Make sure your application.yml files use these credentials"
