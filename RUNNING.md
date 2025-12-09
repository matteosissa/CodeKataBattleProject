# Running Code Kata Battle

## Prerequisites

The application requires:
- **Java 17** or higher
- **PostgreSQL** database
- **Apache Kafka** message broker
- **GitHub OAuth App** (for authentication)

## Initial Setup

### 1. Create GitHub OAuth App

Before running the application, you need to create a GitHub OAuth App:

1. Go to https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Fill in:
   - **Application name**: `CodeKataBattle`
   - **Homepage URL**: `http://localhost:8087`
   - **Authorization callback URL**: `http://localhost:8087/login/oauth2/code/github`
4. Copy your **Client ID** and **Client Secret**

See [GITHUB_OAUTH_SETUP.md](GITHUB_OAUTH_SETUP.md) for detailed instructions.

### 2. Configure OAuth Credentials

**Option A: Environment Variables (Recommended)**
```bash
export GITHUB_CLIENT_ID="your-client-id"
export GITHUB_CLIENT_SECRET="your-client-secret"
```

**Option B: Update application.yml**
Edit `codekatabattle-source/gateway_microservice/src/main/resources/application.yml` and replace the placeholder values.

## Quick Start (Recommended)

### Option 1: Using Docker Compose (Easiest)

1. **Start the infrastructure:**
   ```bash
   docker-compose up -d
   ```

   This starts:
   - PostgreSQL on port 5432 (user: `postgres`, password: `postgres`)
   - Kafka on port 9092
   - Zookeeper on port 2181

2. **Wait for services to be healthy:**
   ```bash
   docker-compose ps
   ```

3. **Build and run the application:**
   ```bash
   ./build-delivery.sh
   cd delivery-ckb
   ./bin/runCKB.sh
   ```

4. **Access the application:**
   - Gateway: http://localhost:8087

5. **Stop everything:**
   ```bash
   # Stop microservices
   cd delivery-ckb
   ./bin/stopCKB.sh
   
   # Stop infrastructure
   cd ..
   docker-compose down
   ```

## Option 2: Manual Setup

If you don't want to use Docker, you need to install and configure:

### PostgreSQL

1. Install PostgreSQL 15+
2. Create database and user:
   ```sql
   CREATE DATABASE ckb;
   CREATE USER postgres WITH PASSWORD 'postgres';
   GRANT ALL PRIVILEGES ON DATABASE ckb TO postgres;
   ```
3. Run SQL scripts from `codekatabattle-source/score_computation_microservice/sql_sonarqube/`

### Kafka

1. Install Apache Kafka
2. Start Zookeeper:
   ```bash
   bin/zookeeper-server-start.sh config/zookeeper.properties
   ```
3. Start Kafka broker:
   ```bash
   bin/kafka-server-start.sh config/server.properties
   ```

## Configuration

If you need different database credentials, update the `application.yml` files in each microservice:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ckb
    username: postgres
    password: postgres
```

For Kafka configuration, check:
- `notification_microservice/src/main/resources/application.yml`

## Microservices Ports

- Gateway: 8087
- Battle: 8083
- User: 8086
- Tournament: 8085
- Notification: 8088
- GitHub Integration: 8090
- Score Computation: 8089

## Troubleshooting

### Database Connection Errors
```
FATAL: password authentication failed for user "postgres"
```
**Solution:** Make sure PostgreSQL is running and credentials match the configuration.

### Kafka Connection Errors
```
Connection to node -1 could not be established
```
**Solution:** Make sure Kafka and Zookeeper are running on port 9092 and 2181.

### Port Already in Use
**Solution:** Make sure no other services are using ports 8083-8090, 5432, 9092, 2181.

Check what's using a port:
```bash
sudo lsof -i :8087
```

## Logs

Application logs are in `delivery-ckb/logs/`:
- `gateway.log`
- `battle.log`
- `user.log`
- `tournament.log`
- `notification.log`
- `github.log`
- `score.log`

View logs in real-time:
```bash
tail -f delivery-ckb/logs/*.log
```
