# Blue-Green Deployment with Flask, Docker 
Project Overview

This project demonstrates a Blue-Green deployment strategy using Flask, Docker, and Nginx.
Enables zero-downtime deployments
Allows instant rollback if something breaks
Containerized microservices architecture for production-ready deployment

# Tech Stack

Python Flask – Sample application
Docker – Containerization
Nginx – Reverse proxy for traffic routing
Windows + PowerShell (local development)
Blue-Green deployment strategy

Step-by-Step Implementation
1️⃣ Flask App

Created a versioned Flask app with / and /health endpoints:

@app.route("/")
def home():
    return "Version 1 - BLUE", 200

@app.route("/health")
def health():
    return "OK", 200


# Error faced: curl unable to connect
Solution: Installed Python properly, ensured Flask was running, used py app.py and checked ports.

2️⃣ Dockerize Flask App

Created Dockerfile:

FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8001
CMD ["python", "app.py"]


# Built images:

docker build -t flask-blue .
docker build -t flask-green .


Error faced: repository does not exist
Solution: Built images locally before running containers.

3️⃣ Run Blue & Green Containers

Created user-defined Docker network:
docker network create bluegreen-net


Ran containers:

docker run -d --name blue --network bluegreen-net -e APP_VERSION=BLUE -p 5001:8001 flask-blue
docker run -d --name green --network bluegreen-net -e APP_VERSION=GREEN -p 5002:8001 flask-green


Error faced: container name conflict
Solution: Removed old containers first: docker rm -f blue green

Error faced: host.docker.internal not reachable / Authentication required
Solution: Switched upstream to container names using Docker network.

4️⃣ Configure Nginx for Traffic Routing

nginx.conf:

events {}

http {
    upstream flask_app {
        server blue:8001;   # BLUE container
        # server green:8001; # GREEN container
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


Run Nginx container:

docker run -d -p 8080:80 --name nginx --network bluegreen-net -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf:ro nginx


Error faced: container not running when running nginx -s reload
Solution: Removed old Nginx container and re-run with correct network and config.

5️⃣ Test Endpoints

Health checks:

curl.exe http://localhost:5001/health   # BLUE
curl.exe http://localhost:5002/health   # GREEN


Nginx routing test:

curl.exe http://localhost:8080/          # Live version
curl.exe http://localhost:8080/health


Error faced: PowerShell curl shows 403 / Authentication
Solution: Use curl.exe instead of alias, avoid host IP; use Docker network container names.

6️⃣ Switch Traffic (Zero-Downtime Deployment)

Edit nginx.conf:

upstream flask_app {
    # server blue:8001;   # BLUE
    server green:8001;    # GREEN
}


Reload Nginx:

docker exec nginx nginx -s reload


Traffic instantly switches without downtime.

Rollback is as simple as switching upstream back to BLUE and reloading.

7️⃣ User Access

Users access via Nginx reverse proxy:

http://localhost:8080/         # Live application
http://localhost:8080/health   # Health check


Internal container ports (5001, 5002) are not used by end-users directly.

8️⃣ Key Takeaways / Best Practices

Never use host.docker.internal for container-to-container communication in Windows → use Docker network + container names

Always verify containers are running before running docker exec

Use /health endpoint for automated monitoring

Nginx handles traffic switching → enables zero-downtime deployment

Always remove old containers before re-running with same names

9️⃣ Future Enhancements

Automate deployment with Jenkins pipeline

Add automatic health check & rollback

Add logging, monitoring, and metrics

Add domain & HTTPS support for production