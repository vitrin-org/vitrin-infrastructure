# Vitrin Infrastructure

Docker containers and deployment configuration for the Vitrin platform - a modern e-commerce and product showcase application.

## 🚀 Features

- **Docker Compose** - Multi-container orchestration
- **Nginx** - Reverse proxy and load balancer
- **Production Ready** - Optimized for production deployment
- **Development Environment** - Easy local development setup
- **SSL/TLS** - HTTPS configuration
- **Environment Management** - Flexible configuration
- **Monitoring** - Health checks and logging

## 🛠️ Tech Stack

- **Containerization**: Docker, Docker Compose
- **Web Server**: Nginx
- **Backend**: Django (Python)
- **Frontend**: React (Node.js)
- **Database**: PostgreSQL
- **Cache**: Redis
- **Storage**: MinIO

## 📦 Quick Start

### Development Environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/vitrin-org/vitrin-infrastructure.git
   cd vitrin-infrastructure
   ```

2. **Start development environment**
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin

### Production Environment

1. **Configure environment**
   ```bash
   cp .env.production .env
   # Edit .env with your production settings
   ```

2. **Deploy to production**
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │   React App     │    │  Django API     │
│   (Port 80/443) │────│   (Port 3000)   │────│   (Port 8000)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   (Port 5432)   │
                    └─────────────────┘
```

## 📁 Project Structure

```
vitrin-infrastructure/
├── docker-compose.yml           # Main compose file
├── docker-compose.override.yml  # Development overrides
├── docker-compose.prod.yml      # Production configuration
├── nginx/
│   └── nginx.conf              # Nginx configuration
├── Dockerfile.frontend         # Frontend Docker image
├── Dockerfile.frontend.dev     # Development frontend image
├── docker-scripts.sh           # Deployment scripts
├── docker-scripts.bat          # Windows deployment scripts
├── DOCKER.md                   # Docker documentation
└── README.md
```

## 🔧 Configuration

### Environment Variables

Create environment files for different stages:

#### Development (.env.development)
```env
# Database
POSTGRES_DB=vitrin_dev
POSTGRES_USER=vitrin
POSTGRES_PASSWORD=vitrin123
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Django
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

# MinIO
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=vitrin-dev
```

#### Production (.env.production)
```env
# Database
POSTGRES_DB=vitrin_prod
POSTGRES_USER=vitrin
POSTGRES_PASSWORD=secure-password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Django
DJANGO_SECRET_KEY=your-production-secret-key
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# MinIO
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=production-access-key
MINIO_SECRET_KEY=production-secret-key
MINIO_BUCKET_NAME=vitrin-prod
```

## 🐳 Docker Services

### Core Services

- **nginx** - Web server and reverse proxy
- **frontend** - React application
- **backend** - Django API server
- **postgres** - PostgreSQL database
- **redis** - Cache and session storage
- **minio** - Object storage

### Development Services

- **frontend-dev** - Development React server with hot reload
- **backend-dev** - Development Django server with auto-reload

## 🚀 Deployment

### Local Development

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild services
docker-compose up -d --build
```

### Production Deployment

```bash
# Deploy to production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Scale services
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Update services
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

### Cloud Deployment

#### AWS ECS
```bash
# Build and push images
docker build -t your-registry/vitrin-frontend .
docker push your-registry/vitrin-frontend

# Deploy with ECS
aws ecs create-service --cluster vitrin-cluster --service-name vitrin-service
```

#### Google Cloud Run
```bash
# Deploy to Cloud Run
gcloud run deploy vitrin-frontend --source .
gcloud run deploy vitrin-backend --source .
```

#### Azure Container Instances
```bash
# Deploy to ACI
az container create --resource-group vitrin-rg --name vitrin-app
```

## 🔒 Security

### SSL/TLS Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/ssl/certs/yourdomain.crt;
    ssl_certificate_key /etc/ssl/private/yourdomain.key;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
```

### Environment Security

- Use secrets management for sensitive data
- Enable Docker content trust
- Regular security updates
- Network isolation between services

## 📊 Monitoring

### Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Logging

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## 🔧 Maintenance

### Database Backups

```bash
# Backup database
docker-compose exec postgres pg_dump -U vitrin vitrin > backup.sql

# Restore database
docker-compose exec -T postgres psql -U vitrin vitrin < backup.sql
```

### Updates

```bash
# Update all services
docker-compose pull
docker-compose up -d

# Update specific service
docker-compose pull frontend
docker-compose up -d frontend
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with docker-compose
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Backend Repository**: https://github.com/vitrin-org/vitrin-backend
- **Frontend Repository**: https://github.com/vitrin-org/vitrin-frontend
- **Documentation**: https://github.com/vitrin-org/vitrin-docs

## 📞 Support

For questions or issues:
- Create an issue in this repository
- Check the Docker documentation
- Review the deployment guides
