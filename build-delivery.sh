#!/bin/bash
# Build script to create the deliverable package
# This script builds all microservices and creates a distribution ZIP

set -e

echo "Building Code Kata Battle Project..."
echo "===================================="

# Navigate to source directory
cd codekatabattle-source

# Clean and build all microservices
echo "Building all microservices..."
mvn clean package -DskipTests

# Create delivery structure
echo ""
echo "Creating delivery package..."
DELIVERY_DIR="../delivery-ckb"
rm -rf "$DELIVERY_DIR"
mkdir -p "$DELIVERY_DIR"

# Copy microservice JARs
echo "Copying microservice JARs..."
mkdir -p "$DELIVERY_DIR/battle_microservice"
mkdir -p "$DELIVERY_DIR/gateway_microservice"
mkdir -p "$DELIVERY_DIR/github_integration_microservice"
mkdir -p "$DELIVERY_DIR/notification_microservice"
mkdir -p "$DELIVERY_DIR/score_computation_microservice"
mkdir -p "$DELIVERY_DIR/tournament_microservice"
mkdir -p "$DELIVERY_DIR/user_microservice"

cp battle_microservice/target/*.jar "$DELIVERY_DIR/battle_microservice/" 2>/dev/null || true
cp gateway_microservice/target/*.jar "$DELIVERY_DIR/gateway_microservice/" 2>/dev/null || true
cp github_integration_microservice/target/*.jar "$DELIVERY_DIR/github_integration_microservice/" 2>/dev/null || true
cp notification_microservice/target/*.jar "$DELIVERY_DIR/notification_microservice/" 2>/dev/null || true
cp score_computation_microservice/target/*.jar "$DELIVERY_DIR/score_computation_microservice/" 2>/dev/null || true
cp tournament_microservice/target/*.jar "$DELIVERY_DIR/tournament_microservice/" 2>/dev/null || true
cp user_microservice/target/*.jar "$DELIVERY_DIR/user_microservice/" 2>/dev/null || true

# Copy SQL scripts
echo "Copying database scripts..."
cp -r score_computation_microservice/sql_sonarqube "$DELIVERY_DIR/score_computation_microservice/" 2>/dev/null || true

# Create run scripts
echo "Creating run scripts..."
mkdir -p "$DELIVERY_DIR/bin"

# Create Linux/Mac run script
cat > "$DELIVERY_DIR/bin/runCKB.sh" << 'EOF'
#!/bin/bash
# Code Kata Battle - Startup Script

# Get the script directory and navigate to parent
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Starting Code Kata Battle Microservices..."
echo "=========================================="

# Function to check if Java is installed
check_java() {
    if ! command -v java &> /dev/null; then
        echo "ERROR: Java is not installed or not in PATH"
        echo "Please install Java 17 or higher"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        echo "ERROR: Java 17 or higher is required"
        exit 1
    fi
    
    echo "Java version: $(java -version 2>&1 | head -n 1)"
}

check_java

# Create logs directory if it doesn't exist
mkdir -p logs

# Start each microservice in background
echo "Starting Gateway Microservice..."
java -jar gateway_microservice/*.jar > logs/gateway.log 2>&1 &
GATEWAY_PID=$!

sleep 5

echo "Starting User Microservice..."
java -jar user_microservice/*.jar > logs/user.log 2>&1 &
USER_PID=$!

echo "Starting Battle Microservice..."
java -jar battle_microservice/*.jar > logs/battle.log 2>&1 &
BATTLE_PID=$!

echo "Starting Tournament Microservice..."
java -jar tournament_microservice/*.jar > logs/tournament.log 2>&1 &
TOURNAMENT_PID=$!

echo "Starting Notification Microservice..."
java -jar notification_microservice/*.jar > logs/notification.log 2>&1 &
NOTIFICATION_PID=$!

echo "Starting GitHub Integration Microservice..."
java -jar github_integration_microservice/*.jar > logs/github.log 2>&1 &
GITHUB_PID=$!

echo "Starting Score Computation Microservice..."
java -jar score_computation_microservice/*.jar > logs/score.log 2>&1 &
SCORE_PID=$!

echo ""
echo "All microservices started!"
echo "Gateway should be available at: http://localhost:8080"
echo ""
echo "Process IDs:"
echo "  Gateway: $GATEWAY_PID"
echo "  User: $USER_PID"
echo "  Battle: $BATTLE_PID"
echo "  Tournament: $TOURNAMENT_PID"
echo "  Notification: $NOTIFICATION_PID"
echo "  GitHub: $GITHUB_PID"
echo "  Score: $SCORE_PID"
echo ""
echo "To stop all services, run: ./bin/stopCKB.sh"
echo "Logs are in the logs/ directory"

# Save PIDs to file for stop script
echo "$GATEWAY_PID $USER_PID $BATTLE_PID $TOURNAMENT_PID $NOTIFICATION_PID $GITHUB_PID $SCORE_PID" > .pids
EOF

# Create Windows run script
cat > "$DELIVERY_DIR/bin/runCKB.bat" << 'EOF'
@echo off
echo Starting Code Kata Battle Microservices...
echo ==========================================

REM Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    exit /b 1
)

if not exist logs mkdir logs

echo Starting Gateway Microservice...
start "Gateway" java -jar gateway_microservice\*.jar > logs\gateway.log 2>&1

timeout /t 5 /nobreak >nul

echo Starting User Microservice...
start "User" java -jar user_microservice\*.jar > logs\user.log 2>&1

echo Starting Battle Microservice...
start "Battle" java -jar battle_microservice\*.jar > logs\battle.log 2>&1

echo Starting Tournament Microservice...
start "Tournament" java -jar tournament_microservice\*.jar > logs\tournament.log 2>&1

echo Starting Notification Microservice...
start "Notification" java -jar notification_microservice\*.jar > logs\notification.log 2>&1

echo Starting GitHub Integration Microservice...
start "GitHub" java -jar github_integration_microservice\*.jar > logs\github.log 2>&1

echo Starting Score Computation Microservice...
start "Score" java -jar score_computation_microservice\*.jar > logs\score.log 2>&1

echo.
echo All microservices started!
echo Gateway should be available at: http://localhost:8080
echo.
echo To stop all services, close the Java windows or use Task Manager
echo Logs are in the logs\ directory
EOF

# Create stop script for Linux/Mac
cat > "$DELIVERY_DIR/bin/stopCKB.sh" << 'EOF'
#!/bin/bash
echo "Stopping Code Kata Battle Microservices..."

if [ -f .pids ]; then
    read -r PIDS < .pids
    for PID in $PIDS; do
        if ps -p $PID > /dev/null 2>&1; then
            echo "Stopping process $PID..."
            kill $PID
        fi
    done
    rm .pids
    echo "All services stopped."
else
    echo "No PID file found. Stopping all java processes for CKB..."
    pkill -f "java -jar.*microservice"
fi
EOF

chmod +x "$DELIVERY_DIR/bin/runCKB.sh"
chmod +x "$DELIVERY_DIR/bin/stopCKB.sh"

# Create logs directory
mkdir -p "$DELIVERY_DIR/logs"

# Create README for the delivery package
cat > "$DELIVERY_DIR/README.md" << 'EOF'
# Code Kata Battle - Executable Package

## Prerequisites

Before running the application, you need:

1. **Java 17 or higher** installed and in PATH
2. **PostgreSQL database** running on localhost:5432
   - Username: `postgres`
   - Password: `postgres`
   - Database: `ckb`
3. **Apache Kafka** running on localhost:9092

### Easy Setup with Docker

The easiest way to set up PostgreSQL and Kafka is using Docker:

```bash
# Download docker-compose.yml from the repository
# Then run:
docker-compose up -d

# Check services are running:
docker-compose ps
```

### Manual Setup

If you prefer to install manually:
- Install PostgreSQL 15+ and create database `ckb`
- Install Apache Kafka and Zookeeper
- Make sure they're running before starting the application

## Quick Start

### Linux/Mac
```bash
cd bin
./runCKB.sh
```

### Windows
```cmd
cd bin
runCKB.bat
```

## Accessing the Application

Once all microservices are running, access the application through the gateway:
- **Gateway**: http://localhost:8087

### All Service Ports:
- Gateway: 8087
- Battle: 8083
- User: 8086
- Tournament: 8085
- Notification: 8088
- GitHub Integration: 8090
- Score Computation: 8089

## Stopping the Application

### Linux/Mac
```bash
cd bin
./stopCKB.sh
```

### Windows
Close the Java console windows or use Task Manager to kill java.exe processes.

## Logs

Application logs are stored in the `logs/` directory:
- gateway.log
- user.log
- battle.log
- tournament.log
- notification.log
- github.log
- score.log

View logs in real-time:
```bash
tail -f logs/*.log
```

## Troubleshooting

### Database Connection Errors
```
FATAL: password authentication failed for user "postgres"
```
**Solution:** 
- Make sure PostgreSQL is running on localhost:5432
- Verify username/password is `postgres`/`postgres`
- Database `ckb` exists

### Kafka Connection Errors
```
Connection to node -1 could not be established
```
**Solution:** 
- Make sure Kafka is running on localhost:9092
- Make sure Zookeeper is running on localhost:2181

### Port Already in Use
```
Port 8087 is already in use
```
**Solution:**
- Check if another instance is running
- Find and stop the process using the port
- Linux: `sudo lsof -i :8087`
- Windows: `netstat -ano | findstr :8087`

### Services Not Starting
Check the logs in the `logs/` directory for specific error messages.

## Database Setup

The SQL scripts for the score computation service are in:
`score_computation_microservice/sql_sonarqube/script_sonarqube.sql`

If using the Docker setup, these are automatically loaded.
EOF

cd ..

echo ""
echo "Build complete!"
echo "Delivery package created at: $DELIVERY_DIR"
echo ""
echo "To create a ZIP for distribution (not for Git):"
echo "  zip -r delivery-ckb.zip delivery-ckb/"
echo ""
echo "Note: Do NOT commit the delivery-ckb folder to Git (it's in .gitignore)"
echo "      Use GitHub Releases to distribute the ZIP file"
