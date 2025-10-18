# OnFly Docker Setup Script para Windows

Write-Host "Iniciando setup do OnFly com Docker..." -ForegroundColor Green

# Verificar se Docker esta instalado
try {
    docker --version | Out-Null
    Write-Host "Docker encontrado" -ForegroundColor Green
} catch {
    Write-Host "Docker nao esta instalado. Por favor, instale o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se Docker Compose esta disponivel
$useDockerCompose = $false
try {
    docker-compose --version | Out-Null
    $useDockerCompose = $true
    Write-Host "Docker Compose (v1) encontrado" -ForegroundColor Green
} catch {
    try {
        docker compose version | Out-Null
        Write-Host "Docker Compose (v2) encontrado" -ForegroundColor Green
    } catch {
        Write-Host "Docker Compose nao esta instalado." -ForegroundColor Red
        exit 1
    }
}

# Copiar arquivo de ambiente se nao existir
$envPath = "api\.env"
$envDockerPath = "api\.env.docker"

if (-not (Test-Path $envPath)) {
    Write-Host "Copiando arquivo de ambiente..." -ForegroundColor Yellow
    Copy-Item $envDockerPath $envPath
    Write-Host "Arquivo .env criado" -ForegroundColor Green
} else {
    Write-Host "Arquivo .env ja existe" -ForegroundColor Green
}

# Construir e iniciar containers
Write-Host "Construindo containers..." -ForegroundColor Yellow
if ($useDockerCompose) {
    docker-compose up --build -d
} else {
    docker compose up --build -d
}

Write-Host "Aguardando containers iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Gerar chave da aplicacao Laravel
Write-Host "Gerando chave da aplicacao Laravel..." -ForegroundColor Yellow
try {
    if ($useDockerCompose) {
        docker-compose exec -T api php artisan key:generate
    } else {
        docker compose exec -T api php artisan key:generate
    }
} catch {
    Write-Host "Erro ao gerar chave. Execute manualmente depois." -ForegroundColor Yellow
}

# Executar migrations
Write-Host "Executando migrations..." -ForegroundColor Yellow
try {
    if ($useDockerCompose) {
        docker-compose exec -T api php artisan migrate --force
    } else {
        docker compose exec -T api php artisan migrate --force
    }
} catch {
    Write-Host "Erro ao executar migrations. Execute manualmente depois." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup completo!" -ForegroundColor Green
Write-Host ""
Write-Host "URLs disponiveis:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   API:      http://localhost:8000" -ForegroundColor White
Write-Host "   Nginx:    http://localhost" -ForegroundColor White
Write-Host ""
Write-Host "Comandos uteis:" -ForegroundColor Cyan
if ($useDockerCompose) {
    Write-Host "   Ver logs:           docker-compose logs -f" -ForegroundColor White
    Write-Host "   Parar containers:   docker-compose down" -ForegroundColor White
    Write-Host "   Reiniciar:          docker-compose restart" -ForegroundColor White
} else {
    Write-Host "   Ver logs:           docker compose logs -f" -ForegroundColor White
    Write-Host "   Parar containers:   docker compose down" -ForegroundColor White
    Write-Host "   Reiniciar:          docker compose restart" -ForegroundColor White
}
Write-Host ""