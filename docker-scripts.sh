#!/bin/bash

# Docker management scripts for Vitrin Project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install it and try again."
        exit 1
    fi
}

# Function to build and start development environment
dev_up() {
    print_status "Starting development environment..."
    check_docker
    check_docker_compose
    
    docker-compose up --build -d
    print_success "Development environment started!"
    print_status "Frontend: http://localhost:5173"
    print_status "Backend API: http://localhost:8000/api"
    print_status "Database: localhost:5432"
    print_status "Redis: localhost:6379"
}

# Function to start production environment
prod_up() {
    print_status "Starting production environment..."
    check_docker
    check_docker_compose
    
    # Check if production env file exists
    if [ ! -f .env ]; then
        print_warning "Production environment file (.env) not found."
        print_status "Copying template from env.production..."
        cp env.production .env
        print_warning "Please edit .env file with your production values before continuing."
        read -p "Press Enter when ready to continue..."
    fi
    
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
    print_success "Production environment started!"
    print_status "Frontend: https://localhost"
    print_status "Backend API: https://localhost/api"
}

# Function to stop all services
down() {
    print_status "Stopping all services..."
    docker-compose down
    print_success "All services stopped!"
}

# Function to stop and remove all containers, networks, and volumes
down_all() {
    print_status "Stopping and removing all containers, networks, and volumes..."
    docker-compose down -v --remove-orphans
    print_success "All containers, networks, and volumes removed!"
}

# Function to view logs
logs() {
    if [ -z "$1" ]; then
        print_status "Showing logs for all services..."
        docker-compose logs -f
    else
        print_status "Showing logs for service: $1"
        docker-compose logs -f "$1"
    fi
}

# Function to rebuild services
rebuild() {
    print_status "Rebuilding services..."
    docker-compose build --no-cache
    print_success "Services rebuilt!"
}

# Function to execute commands in containers
exec_backend() {
    print_status "Executing command in backend container..."
    docker-compose exec backend "$@"
}

exec_frontend() {
    print_status "Executing command in frontend container..."
    docker-compose exec frontend "$@"
}

exec_db() {
    print_status "Executing command in database container..."
    docker-compose exec db "$@"
}

# Function to create superuser
create_superuser() {
    print_status "Creating superuser..."
    docker-compose exec backend python vitrin/manage.py createsuperuser
}

# Function to run migrations
migrate() {
    print_status "Running migrations..."
    docker-compose exec backend python vitrin/manage.py migrate
    print_success "Migrations completed!"
}

# Function to collect static files
collectstatic() {
    print_status "Collecting static files..."
    docker-compose exec backend python vitrin/manage.py collectstatic --noinput
    print_success "Static files collected!"
}

# Function to show status
status() {
    print_status "Container status:"
    docker-compose ps
}

# Function to show resource usage
resources() {
    print_status "Resource usage:"
    docker stats --no-stream
}

# Function to clean up unused Docker resources
cleanup() {
    print_status "Cleaning up unused Docker resources..."
    docker system prune -f
    print_success "Cleanup completed!"
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  dev-up          Start development environment"
    echo "  prod-up         Start production environment"
    echo "  down            Stop all services"
    echo "  down-all        Stop and remove all containers, networks, and volumes"
    echo "  logs [SERVICE]  Show logs (all services or specific service)"
    echo "  rebuild         Rebuild all services"
    echo "  exec-backend    Execute command in backend container"
    echo "  exec-frontend   Execute command in frontend container"
    echo "  exec-db         Execute command in database container"
    echo "  create-superuser Create Django superuser"
    echo "  migrate         Run Django migrations"
    echo "  collectstatic   Collect static files"
    echo "  status          Show container status"
    echo "  resources       Show resource usage"
    echo "  cleanup         Clean up unused Docker resources"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev-up"
    echo "  $0 logs backend"
    echo "  $0 exec-backend python vitrin/manage.py shell"
}

# Main script logic
case "${1:-help}" in
    dev-up)
        dev_up
        ;;
    prod-up)
        prod_up
        ;;
    down)
        down
        ;;
    down-all)
        down_all
        ;;
    logs)
        logs "$2"
        ;;
    rebuild)
        rebuild
        ;;
    exec-backend)
        shift
        exec_backend "$@"
        ;;
    exec-frontend)
        shift
        exec_frontend "$@"
        ;;
    exec-db)
        shift
        exec_db "$@"
        ;;
    create-superuser)
        create_superuser
        ;;
    migrate)
        migrate
        ;;
    collectstatic)
        collectstatic
        ;;
    status)
        status
        ;;
    resources)
        resources
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
