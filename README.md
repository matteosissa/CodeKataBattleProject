# 🏆 Code Kata Battle

<div align="center">


### A modern platform for competitive programming tournaments and coding challenges

*Compete, Learn, and Master Your Coding Skills* 🚀

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/) [![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)](https://spring.io/projects/spring-boot) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<img src="Home.png" alt="Code Kata Battle Platform" width="600"/>


</div>

---

## 🎯 What is Code Kata Battle?

Code Kata Battle is a comprehensive microservices-based platform designed to facilitate competitive programming tournaments in educational settings. It enables educators to create coding challenges, students to participate in battles, and automated evaluation of submissions through GitHub integration.

---

## 🏗️ Architecture

This project follows a **microservices architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                    Gateway Service                      │
│         (OAuth2, Routing, Frontend Serving)             │
└────────────┬────────────────────────────────────────────┘
             │
    ┌────────┴────────┬────────────┬──────────────┬────────────┐
    │                 │            │              │            │
┌───▼────┐    ┌──────▼─────┐  ┌──▼─────┐  ┌─────▼──────┐ ┌──▼──────────┐
│  User  │    │ Tournament │  │ Battle │  │   GitHub   │ │    Score    │
│Service │    │  Service   │  │Service │  │Integration │ │ Computation │
└───┬────┘    └──────┬─────┘  └──┬─────┘  └─────┬──────┘ └──────┬──────┘
    │                │           │              │               │
    └────────┬───────┴───────────┴──────────────┴───────────────┘
             │
    ┌────────▼────────────────────────────────────┐
    │         Notification Service                │
    │      (Kafka Consumer, Event Handler)        │
    └─────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────┐
    │           Infrastructure Layer              │
    │  PostgreSQL | Kafka | Zookeeper | Docker   │
    └─────────────────────────────────────────────┘
```

### Microservices

| Service | Port | Purpose |
|---------|------|---------|
| **Gateway** | 8087 | API gateway, OAuth2 authentication, frontend serving |
| **User** | 8086 | User management and authentication |
| **Tournament** | 8085 | Tournament lifecycle management |
| **Battle** | 8083 | Coding battle management |
| **GitHub Integration** | 8090 | GitHub API integration for code retrieval |
| **Score Computation** | 8089 | SonarQube integration for code quality scoring |
| **Notification** | 8088 | Event processing and real-time notifications |

---

## 💻 Technology Stack

### Backend
- ☕ **Java 17** - Modern Java with enhanced features
- 🍃 **Spring Boot 2.7/3.2** - Microservices framework
- 🔐 **Spring Security OAuth2** - GitHub authentication
- 🗄️ **PostgreSQL** - Relational database
- 📨 **Apache Kafka** - Event streaming platform
- 🎨 **Thymeleaf** - Server-side template engine

### Frontend
- 🎭 **Thymeleaf Templates** - Dynamic HTML rendering
- 🎨 **Bootstrap 5** - Responsive UI framework
- ⚡ **jQuery** - DOM manipulation and AJAX
- 🔤 **Inter Font** - Modern typography
- 🎨 **Modern UI** - Purple gradient design with glassmorphism effects

### Infrastructure
- 🐳 **Docker Compose** - Container orchestration
- 🛠️ **Maven** - Build automation and dependency management
- 📊 **SonarQube** - Code quality analysis
- 🐙 **GitHub API** - Source code integration

---

## 🚀 Quick Start

### Prerequisites

- ☕ Java 17 or higher
- 🔨 Maven 3.8+
- 🐳 Docker & Docker Compose
- 🐙 GitHub OAuth App ([Create one here](https://github.com/settings/developers))

### 1. Clone the Repository

```bash
git clone https://github.com/matteosissa/CodeKataBattleProject.git
cd CodeKataBattleProject
```

### 2. Configure GitHub OAuth

Update `codekatabattle-source/gateway_microservice/src/main/resources/application.yml`:

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          github:
            client-id: YOUR_GITHUB_CLIENT_ID
            client-secret: YOUR_GITHUB_CLIENT_SECRET
```

Or use the provided default credentials for quick testing (development only).

### 3. Start Infrastructure

```bash
docker-compose up -d
```

This starts:
- 🐘 PostgreSQL on port 5432
- 📨 Kafka on port 9092
- 🦁 Zookeeper on port 2181

### 4. Build the Application

```bash
./build-delivery.sh
```

This script:
- ✅ Compiles all 7 microservices
- 📦 Packages them into executable JARs
- 📁 Creates the `delivery-ckb` folder with run scripts

### 5. Run the Application

```bash
cd delivery-ckb
./bin/runCKB.sh
```

Wait for all services to start (approximately 30-60 seconds).

### 6. Access the Platform

Open your browser and navigate to:

```
http://localhost:8087
```

🎉 **You're ready to compete!**

---

## 📖 Usage

### For Educators 👨‍🏫

1. **Login** with your GitHub account
2. **Update your role** (first time only):
   ```sql
   docker exec -i $(docker ps -qf "name=postgres") psql -U postgres -d ckb_db \
     -c "UPDATE user_model SET role = 1 WHERE username = 'your-github-username';"
   ```
3. **Create a Tournament**
   - Click "Create a new tournament"
   - Set registration and submission deadlines
   - Add tournament description
4. **Create Battles** within the tournament
   - Link GitHub repository with test cases
   - Configure team size and deadlines
5. **Monitor Progress**
   - View student submissions
   - Track scores and rankings
   - End tournaments when complete

### For Students 👨‍🎓

1. **Login** with your GitHub account
2. **Browse Tournaments**
   - Click "Display all tournaments"
   - View available tournaments with deadlines
3. **Subscribe to Tournaments**
   - Select a tournament
   - Join battles within tournaments
   - Form teams with other students
4. **Compete**
   - Submit code via GitHub
   - View real-time scores
   - Check your ranking
5. **Receive Notifications**
   - Click the "Notifications" button
   - Get updates on scores and rankings

---

## 🛠️ Configuration

### Database Configuration

Default credentials (defined in `docker-compose.yml`):

```yaml
POSTGRES_DB: ckb_db
POSTGRES_USER: postgres
POSTGRES_PASSWORD: postgres
```

### Microservice Configuration

Each microservice can be configured via `application.yml`:

```yaml
server:
  port: 8087  # Gateway port

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ckb_db
    username: postgres
    password: postgres
```

### Kafka Configuration

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: notification-group
```

---

## 🔧 Development

### Project Structure

```
CodeKataBattleProject/
├── codekatabattle-source/          # Source code
│   ├── gateway_microservice/       # Gateway & Frontend
│   ├── user_microservice/          # User management
│   ├── tournament_microservice/    # Tournament logic
│   ├── battle_microservice/        # Battle management
│   ├── github_integration_microservice/
│   ├── score_computation_microservice/
│   └── notification_microservice/
├── docs/                           # Documentation and screenshots
├── docker-compose.yml              # Infrastructure setup
├── build-delivery.sh               # Build automation script
└── delivery-ckb/                   # Compiled artifacts (gitignored)
    ├── bin/
    │   ├── runCKB.sh              # Start all services
    │   └── stopCKB.sh             # Stop all services
    └── [microservice-name]/        # Individual JARs
```

### Building Individual Microservices

```bash
cd codekatabattle-source/[microservice-name]
mvn clean package
```

### Running Individual Services

```bash
java -jar target/[microservice-name]-0.0.1-SNAPSHOT.jar
```

### Stopping Services

```bash
cd delivery-ckb
./bin/stopCKB.sh
```

---

## 🐛 Troubleshooting

### Common Issues

#### Services Won't Start

```bash
# Check if ports are already in use
lsof -i :8087

# Kill existing processes
pkill -f "java -jar.*microservice"
```

#### Database Connection Errors

```bash
# Verify PostgreSQL is running
docker ps | grep postgres

# Check database exists
docker exec -it ckb-postgres psql -U postgres -l

# Recreate database
docker-compose down -v
docker-compose up -d
```

#### GitHub OAuth Not Working

1. Verify OAuth app configuration in GitHub
2. Check client ID and secret in `application.yml`
3. Ensure callback URL is: `http://localhost:8087/login/oauth2/code/github`
4. Make sure your OAuth app is set to "Public" or your account has access

#### Kafka Connection Issues

```bash
# Restart Kafka and Zookeeper
docker-compose restart kafka zookeeper

# Check Kafka logs
docker logs ckb-kafka

# Verify Kafka is healthy
docker exec -it ckb-kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

#### "Display tournaments" Shows Nothing

This usually means you're logged in as a student but trying to view educator tournaments, or vice versa:

```bash
# Check your role (0 = student, 1 = educator)
docker exec -i ckb-postgres psql -U postgres -d ckb_db \
  -c "SELECT * FROM user_model WHERE username = 'your-github-username';"

# Change to educator
docker exec -i ckb-postgres psql -U postgres -d ckb_db \
  -c "UPDATE user_model SET role = 1 WHERE username = 'your-github-username';"
```

---

## 📊 Database Schema

### Key Tables

- **user_model** - User accounts and roles (educator/student)
- **tournament_model** - Tournament metadata and deadlines
- **battle_model** - Battle configurations and GitHub repo links
- **tournament_battle_student_team_score** - Team scores and rankings
- **tournament_student_score** - Overall tournament scores

### Adding Test Data

```bash
docker exec -i ckb-postgres psql -U postgres -d ckb_db << 'EOF'
INSERT INTO tournament_model (creator, end_date, ended, name, subscription_deadline) 
VALUES 
('your-github-username', '2025-12-31', false, 'Test Tournament', '2025-12-20'),
('your-github-username', '2026-01-15', false, 'Spring Challenge', '2025-12-25');
EOF
```

---

## 🎨 UI Features

The platform features a modern, professional UI with:

- 💜 **Purple Gradient Background** - Eye-catching design inspired by modern coding platforms
- 🎯 **Glassmorphism Effects** - Translucent cards with backdrop blur
- 🔔 **Toast Notifications** - Elegant slide-in notifications for user feedback
- 📱 **Responsive Design** - Works seamlessly on desktop and mobile
- ⚡ **Smooth Animations** - Hover effects and transitions throughout
- 🎨 **Inter Font** - Clean, modern typography

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project was developed as part of a Software Engineering course project at Politecnico di Milano.

---

## 👥 Team

Developed with ❤️ by the Code Kata Battle team for Software Engineering 2 course.

---

## 🙏 Acknowledgments

- 🍃 Spring Boot community for excellent documentation
- 🐙 GitHub for OAuth integration and API
- 📨 Apache Kafka for reliable event streaming
- 🐘 PostgreSQL for robust data persistence
- 🌐 The open-source community for amazing tools and libraries

---

<div align="center">
  
  **Made with** ☕ **and** 💜
  
  [Report Bug](https://github.com/matteosissa/CodeKataBattleProject/issues) · [Request Feature](https://github.com/matteosissa/CodeKataBattleProject/issues)
  
</div>
