@echo off
setlocal enabledelayedexpansion

REM Docker management scripts for Vitrin Project (Windows)

if "%1"=="" goto help

if "%1"=="dev-up" goto dev_up
if "%1"=="prod-up" goto prod_up
if "%1"=="down" goto down
if "%1"=="down-all" goto down_all
if "%1"=="logs" goto logs
if "%1"=="rebuild" goto rebuild
if "%1"=="status" goto status
if "%1"=="cleanup" goto cleanup
if "%1"=="help" goto help

echo Unknown command: %1
goto help

:dev_up
echo [INFO] Starting development environment...
docker-compose up --build -d
if %errorlevel% equ 0 (
    echo [SUCCESS] Development environment started!
    echo [INFO] Frontend: http://localhost:5173
    echo [INFO] Backend API: http://localhost:8000/api
    echo [INFO] Database: localhost:5432
    echo [INFO] Redis: localhost:6379
) else (
    echo [ERROR] Failed to start development environment
)
goto end

:prod_up
echo [INFO] Starting production environment...
if not exist .env (
    echo [WARNING] Production environment file (.env) not found.
    echo [INFO] Copying template from env.production...
    copy env.production .env
    echo [WARNING] Please edit .env file with your production values before continuing.
    pause
)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
if %errorlevel% equ 0 (
    echo [SUCCESS] Production environment started!
    echo [INFO] Frontend: https://localhost
    echo [INFO] Backend API: https://localhost/api
) else (
    echo [ERROR] Failed to start production environment
)
goto end

:down
echo [INFO] Stopping all services...
docker-compose down
if %errorlevel% equ 0 (
    echo [SUCCESS] All services stopped!
) else (
    echo [ERROR] Failed to stop services
)
goto end

:down_all
echo [INFO] Stopping and removing all containers, networks, and volumes...
docker-compose down -v --remove-orphans
if %errorlevel% equ 0 (
    echo [SUCCESS] All containers, networks, and volumes removed!
) else (
    echo [ERROR] Failed to remove containers
)
goto end

:logs
if "%2"=="" (
    echo [INFO] Showing logs for all services...
    docker-compose logs -f
) else (
    echo [INFO] Showing logs for service: %2
    docker-compose logs -f %2
)
goto end

:rebuild
echo [INFO] Rebuilding services...
docker-compose build --no-cache
if %errorlevel% equ 0 (
    echo [SUCCESS] Services rebuilt!
) else (
    echo [ERROR] Failed to rebuild services
)
goto end

:status
echo [INFO] Container status:
docker-compose ps
goto end

:cleanup
echo [INFO] Cleaning up unused Docker resources...
docker system prune -f
if %errorlevel% equ 0 (
    echo [SUCCESS] Cleanup completed!
) else (
    echo [ERROR] Failed to cleanup
)
goto end

:help
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   dev-up          Start development environment
echo   prod-up         Start production environment
echo   down            Stop all services
echo   down-all        Stop and remove all containers, networks, and volumes
echo   logs [SERVICE]  Show logs (all services or specific service)
echo   rebuild         Rebuild all services
echo   status          Show container status
echo   cleanup         Clean up unused Docker resources
echo   help            Show this help message
echo.
echo Examples:
echo   %0 dev-up
echo   %0 logs backend
echo.
goto end

:end
endlocal

