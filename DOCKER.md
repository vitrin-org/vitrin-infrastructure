# 🐳 Docker Setup for Vitrin Project

This document provides comprehensive instructions for running the Vitrin project using Docker and Docker Compose.

## 📋 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0+)
- At least 4GB of available RAM
- At least 10GB of available disk space

## 🚀 Quick Start

### 1. Development Environment

```bash
# Start development environment
./docker-scripts.sh dev-up

# Or on Windows
docker-scripts.bat dev-up
```

**Access Points:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api
- Database: localhost:5432
- Redis: localhost:6379

### 2. Production Environment

```bash
# Start production environment
./docker-scripts.sh prod-up

# Or on Windows
docker-scripts.bat prod-up
```

**Access Points:**
- Frontend: https://localhost
- Backend API: https://localhost/api
- Django Admin: https://localhost/admin

## 🏗️ Architecture

The Docker setup includes the following services:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Nginx     │    │  Frontend   │    │   Backend   │
│  (Port 80)  │◄──►│  (Port 3000)│◄──►│  (Port 8000)│
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ PostgreSQL  │    │    Redis    │    │   Celery    │
│  (Port 5432)│    │  (Port 6379)│    │   Workers   │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 📁 File Structure

```
├── Dockerfile.frontend          # React frontend Dockerfile
├── docker-compose.yml           # Main Docker Compose file
├── docker-compose.override.yml  # Development overrides
├── docker-compose.prod.yml      # Production overrides
├── docker-scripts.sh            # Unix/Linux management script
├── docker-scripts.bat           # Windows management script
├── env.production               # Production environment template
├── nginx/
│   └── nginx.conf              # Nginx configuration
└── backend/
    ├── Dockerfile               # Django backend Dockerfile
    └── init.sql                 # Database initialization
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root for production:

```bash
# Copy template
cp env.production .env

# Edit with your values
nano .env
```

**Key Variables:**
- `SECRET_KEY`: Django secret key
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts
- `CORS_ALLOWED_ORIGINS`: Comma-separated list of CORS origins

### Database Configuration

The system automatically detects the environment:
- **Docker**: Uses PostgreSQL with connection pooling
- **Local**: Falls back to SQLite for development

## 🛠️ Management Commands

### Using Scripts

```bash
# Development
./docker-scripts.sh dev-up
./docker-scripts.sh down

# Production
./docker-scripts.sh prod-up
./docker-scripts.sh down

# View logs
./docker-scripts.sh logs backend
./docker-scripts.sh logs frontend

# Execute commands
./docker-scripts.sh exec-backend python vitrin/manage.py shell
./docker-scripts.sh exec-db psql -U vitrin_user -d vitrin

# Cleanup
./docker-scripts.sh down-all
./docker-scripts.sh cleanup
```

### Using Docker Compose Directly

```bash
# Start services
docker-compose up -d

# Start with build
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove volumes
docker-compose down -v
```

## 🔧 Development Workflow

### 1. Start Development Environment

```bash
./docker-scripts.sh dev-up
```

### 2. Make Code Changes

The development setup includes volume mounts for hot reloading:
- Frontend changes are reflected immediately
- Backend changes require container restart (or use Django's auto-reload)

### 3. View Logs

```bash
# All services
./docker-scripts.sh logs

# Specific service
./docker-scripts.sh logs backend
```

### 4. Execute Commands

```bash
# Django shell
./docker-scripts.sh exec-backend python vitrin/manage.py shell

# Create superuser
./docker-scripts.sh create-superuser

# Run migrations
./docker-scripts.sh migrate
```

## 🚀 Production Deployment

### 1. Prepare Environment

```bash
# Copy production template
cp env.production .env

# Edit production values
nano .env
```

### 2. Start Production Services

```bash
./docker-scripts.sh prod-up
```

### 3. SSL Configuration

For production, you'll need SSL certificates:

```bash
# Create SSL directory
mkdir -p nginx/ssl

# Add your certificates
cp your-cert.pem nginx/ssl/cert.pem
cp your-key.pem nginx/ssl/key.pem
```

### 4. Scale Services

```bash
# Scale Celery workers
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale celery=3

# Scale frontend (with load balancer)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale frontend=2
```

## 📊 Monitoring and Logs

### Container Status

```bash
./docker-scripts.sh status
```

### Resource Usage

```bash
./docker-scripts.sh resources
```

### Log Analysis

```bash
# Real-time logs
./docker-scripts.sh logs

# Specific service logs
./docker-scripts.sh logs backend

# Follow logs
docker-compose logs -f --tail=100 backend
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Port Conflicts

```bash
# Check what's using a port
netstat -tulpn | grep :8000

# Stop conflicting service or change ports in docker-compose.yml
```

#### 2. Database Connection Issues

```bash
# Check database container
docker-compose ps db

# View database logs
docker-compose logs db

# Test connection
./docker-scripts.sh exec-backend python vitrin/manage.py dbshell
```

#### 3. Memory Issues

```bash
# Check resource usage
./docker-scripts.sh resources

# Clean up Docker
./docker-scripts.sh cleanup

# Restart Docker service
sudo systemctl restart docker
```

#### 4. Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker socket permissions
sudo usermod -aG docker $USER
```

### Debug Mode

```bash
# Start with debug output
docker-compose up

# Rebuild without cache
./docker-scripts.sh rebuild
```

## 🔒 Security Considerations

### Production Security

1. **Change Default Passwords**
   - Database passwords
   - Django secret key
   - JWT secret keys

2. **Network Security**
   - Use internal Docker networks
   - Limit exposed ports
   - Use reverse proxy (Nginx)

3. **SSL/TLS**
   - Enable HTTPS
   - Use strong cipher suites
   - Implement HSTS

4. **Access Control**
   - Restrict admin access
   - Use environment variables for secrets
   - Implement rate limiting

## 📈 Performance Optimization

### Resource Limits

```yaml
# In docker-compose.prod.yml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
    reservations:
      memory: 512M
      cpus: '0.25'
```

### Scaling Strategies

```bash
# Scale backend services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale backend=2

# Scale Celery workers
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale celery=4
```

### Caching

- Redis for session storage
- Redis for Celery broker
- Django cache framework
- Static file caching via Nginx

## 🧹 Maintenance

### Regular Tasks

```bash
# Weekly cleanup
./docker-scripts.sh cleanup

# Monthly rebuild
./docker-scripts.sh rebuild

# Check for updates
docker-compose pull
```

### Backup Strategy

```bash
# Database backup
docker-compose exec db pg_dump -U vitrin_user vitrin > backup.sql

# Media files backup
docker run --rm -v vitrin_media_files:/data -v $(pwd):/backup alpine tar czf /backup/media_backup.tar.gz -C /data .

# Restore database
docker-compose exec -T db psql -U vitrin_user vitrin < backup.sql
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [Redis Docker](https://hub.docker.com/_/redis)

## 🤝 Support

If you encounter issues:

1. Check the logs: `./docker-scripts.sh logs`
2. Verify Docker is running: `docker info`
3. Check container status: `./docker-scripts.sh status`
4. Review this documentation
5. Check GitHub issues for similar problems

---

**Happy Containerizing! 🐳✨**

