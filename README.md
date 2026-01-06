# 🚀 Zero-Downtime Blue-Green Deployment

![Python](https://img.shields.io/badge/Python-3.9+-blue?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-2.0+-green?logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-20.10+-blue?logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-1.21+-green?logo=nginx&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)
![GitHub](https://img.shields.io/badge/GitHub-Zero--Downtime--Blue--Green--Deployment-black?logo=github)

A production-ready implementation of Blue-Green deployment strategy using Flask, Docker, and Nginx for achieving zero-downtime deployments with instant rollback capabilities.

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Installation & Setup](#-installation--setup)
- [Usage](#-usage)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Future Enhancements](#-future-enhancements)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

## 🎯 Overview

Blue-Green deployment is a technique that reduces downtime and risk by running two identical production environments called **Blue** and **Green**. At any time, only one of the environments is live, with the other serving as a staging environment for the next release.

### How it works:

1. 🔵 **Blue Environment**: Currently serving live traffic
2. 🟢 **Green Environment**: Staging the new version
3. 🔄 **Switch**: Traffic is instantly redirected from Blue to Green
4. ⏪ **Rollback**: If issues arise, traffic switches back to Blue immediately

This project demonstrates the concept using containerized Flask applications with Nginx as a reverse proxy for traffic management.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│     Users       │───▶│   Nginx Proxy   │
│                 │    │   (Port 8080)   │
└─────────────────┘    └─────────────────┘
                               │
                               ▼
                    ┌─────────────────┐
                    │ Docker Network  │
                    │  (bluegreen-net)│
                    └─────────────────┘
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
            ┌─────────────┐       ┌─────────────┐
            │🔵 Blue App  │       │🟢 Green App │
            │(Port 5001)  │       │(Port 5002)  │
            │Flask v1     │       │Flask v2     │
            └─────────────┘       └─────────────┘
```

## ✨ Features

- ✅ **Zero-Downtime Deployments**: Seamless traffic switching
- ✅ **Instant Rollback**: Switch back to previous version in seconds
- ✅ **Health Checks**: Built-in health monitoring endpoints
- ✅ **Containerized**: Docker-based architecture for consistency
- ✅ **Load Balancing**: Nginx reverse proxy for traffic management
- ✅ **Version Control**: Easy version tracking and management
- ✅ **Production Ready**: Scalable architecture patterns

## 🛠️ Tech Stack

| Technology           | Version | Purpose                       |
| -------------------- | ------- | ----------------------------- |
| Python               | 3.9+    | Application runtime           |
| Flask                | 2.0+    | Web framework                 |
| Docker               | 20.10+  | Containerization              |
| Nginx                | 1.21+   | Reverse proxy & load balancer |
| PowerShell           | 5.1+    | Deployment scripts (Windows)  |

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- 🐳 [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v20.10+)
- 🐍 [Python](https://www.python.org/downloads/) (v3.9+)
- 💻 PowerShell (Windows) or Bash (Linux/macOS)
- 🌐 [curl](https://curl.se/download.html) for testing endpoints

## 📁 Project Structure

```
Zero-Downtime-Blue-Green-Deployment/
│
├── 📄 app.py                 # Flask application
├── 📄 Dockerfile             # Docker container configuration
├── 📄 requirements.txt       # Python dependencies
├── 📄 nginx.conf             # Nginx proxy configuration
├── 📄 README.md              # Project documentation
└── 📁 scripts/               # Deployment scripts (optional)

```

## 🚀 Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/kiranz9871/Zero-Downtime-Blue-Green-Deployment.git
cd Zero-Downtime-Blue-Green-Deployment
```

### Step 2: Create Docker Network

```bash
docker network create bluegreen-net
```

### Step 3: Build Docker Images

```bash
# Build Blue version (v1)
docker build -t flask-blue .

# For Green version, modify app.py to show "Version 2 - GREEN"
# Then build Green version
docker build -t flask-green .
```

### Step 4: Run Blue and Green Containers

```bash
# Start Blue container
docker run -d --name blue --network bluegreen-net -e APP_VERSION=BLUE -p 5001:8001 flask-blue

# Start Green container  
docker run -d --name green --network bluegreen-net -e APP_VERSION=GREEN -p 5002:8001 flask-green
```

### Step 5: Configure and Start Nginx

```bash
# Run Nginx with custom configuration
docker run -d -p 8080:80 --name nginx --network bluegreen-net -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf:ro nginx
```

## 🎮 Usage

### Initial Deployment (Blue Environment Live)

**nginx.conf** configuration for Blue environment:

```nginx
events {}

http {
    upstream flask_app {
        server blue:8001;    # 🔵 Blue is live
        # server green:8001; # 🟢 Green is standby
    }

    server {
        listen 80;
      
        location / {
            proxy_pass http://flask_app;
        }
      
        location /health {
            proxy_pass http://flask_app/health;
        }
    }
}
```

### Zero-Downtime Deployment (Switch to Green)

1. **Update nginx.conf** to point to Green:

```nginx
upstream flask_app {
    # server blue:8001;  # 🔵 Blue is now standby
    server green:8001;   # 🟢 Green is now live
}
```

2. **Reload Nginx configuration** (zero-downtime switch):

```bash
docker exec nginx nginx -s reload
```

3. **Verify the switch**:

```bash
curl http://localhost:8080/
# Should show: "Version 2 - GREEN"
```

### Instant Rollback (Switch back to Blue)

If issues are detected, rollback instantly:

1. **Revert nginx.conf**:

```nginx
upstream flask_app {
    server blue:8001;    # 🔵 Blue is live again
    # server green:8001; # 🟢 Green is standby
}
```

2. **Reload Nginx**:

```bash
docker exec nginx nginx -s reload
```

## 🧪 Testing

### Health Check Endpoints

```bash
# Test individual containers
curl http://localhost:5001/health  # Blue health
curl http://localhost:5002/health  # Green health

# Test through Nginx proxy
curl http://localhost:8080/health  # Current live environment
curl http://localhost:8080/        # Current live version
```

### Load Testing (Optional)

```bash
# Continuous testing during deployment
while true; do curl -s http://localhost:8080/ && sleep 1; done
```

### Expected Responses

| Endpoint    | Blue Response        | Green Response        |
| ----------- | -------------------- | --------------------- |
| `/`         | `Version 1 - BLUE`   | `Version 2 - GREEN` |
| `/health`   | `OK`                 | `OK`                |


## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. 🚫 Container Name Conflicts

**Error**: `Conflict. The container name "/blue" is already in use`

**Solution**:

```bash
# Remove existing containers
docker rm -f blue green nginx

# Re-run the containers
docker run -d --name blue --network bluegreen-net -e APP_VERSION=BLUE -p 5001:8001 flask-blue
```

#### 2. 🌐 Network Connectivity Issues

**Error**: `curl: (7) Failed to connect to localhost`

**Solution**:

```bash
# Verify containers are running
docker ps

# Check network connectivity
docker network inspect bluegreen-net

# Use container names in nginx.conf, not IP addresses
```

#### 3. 🔄 Nginx Configuration Not Reloading

**Error**: `nginx: [error] open() "/var/run/nginx.pid" failed`

**Solution**:

```bash
# Check nginx container status
docker logs nginx

# Restart nginx container
docker restart nginx

# Test configuration before reload
docker exec nginx nginx -t
```

#### 4. 📁 Volume Mount Issues (Windows)

**Error**: `docker: invalid mode: /etc/nginx/nginx.conf:ro`

**Solution (PowerShell)**:

```powershell
# Use full Windows path
docker run -d -p 8080:80 --name nginx --network bluegreen-net -v "${PWD}/nginx.conf:/etc/nginx/nginx.conf:ro" nginx
```

#### 5. 🔍 Flask App Not Responding

**Error**: `502 Bad Gateway`

**Solution**:

```bash
# Check Flask app logs
docker logs blue
docker logs green

# Ensure Flask is binding to 0.0.0.0, not localhost
# In app.py: app.run(host="0.0.0.0", port=8001)
```

## 🚀 Future Enhancements

- [ ] **Automated Health Checks**: Implement automated health monitoring and rollback
- [ ] **CI/CD Pipeline**: Jenkins/GitHub Actions integration for automated deployments
- [ ] **Database Migration**: Handle database schema changes during deployments
- [ ] **Multi-Environment**: Support for staging, UAT, and production environments
- [ ] **Monitoring & Logging**: Integrate Prometheus, Grafana, and centralized logging
- [ ] **HTTPS Support**: Add SSL/TLS certificates for production use
- [ ] **Kubernetes Deployment**: Migrate to Kubernetes for advanced orchestration
- [ ] **Canary Deployment**: Implement canary deployment strategy
- [ ] **Blue-Green Database**: Handle database deployments with blue-green pattern

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow PEP 8 for Python code style
- Add comments for complex logic
- Include tests for new features
- Update documentation for any changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Kiran Zirpe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 👨‍💻 Author

**Kiran Zirpe**

- 📧 Email: [kiranzirpe.devops@gmail.com](mailto:kiranzirpe.devops@gmail.com)
- 💼 LinkedIn: [kiran-zirpe-26068b146](https://www.linkedin.com/in/kiran-zirpe-26068b146)
- 🐙 GitHub: [@kiranz9871](https://github.com/kiranz9871)
- 📱 Phone: +91 9503500940

---

⭐ **If this project helped you, please give it a star!** ⭐

**Made with ❤️ by [Kiran Zirpe](https://github.com/kiranz9871)**