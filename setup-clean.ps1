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

# Aguardar containers iniciarem com verificacao de saude
Write-Host "Aguardando containers iniciarem..." -ForegroundColor Yellow
$maxWait = 120  # 2 minutos
$waited = 0
$step = 10

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $step
    $waited += $step
    
    Write-Host "Verificando status dos containers ($waited/$maxWait segundos)..." -ForegroundColor Yellow
    
    # Verificar se PostgreSQL esta saudavel
    $pgHealth = docker inspect onfly_postgres --format '{{.State.Health.Status}}' 2>$null
    if ($pgHealth -eq "healthy") {
        Write-Host "PostgreSQL esta saudavel!" -ForegroundColor Green
        break
    }
    
    if ($waited -ge $maxWait) {
        Write-Host "Aviso: Timeout aguardando PostgreSQL. Continuando mesmo assim..." -ForegroundColor Yellow
        break
    }
}

# Criar diretorios necessarios do Laravel
Write-Host "Criando diretorios necessarios..." -ForegroundColor Yellow
try {
    docker exec onfly_api mkdir -p /var/www/html/bootstrap/cache /var/www/html/storage/logs /var/www/html/storage/framework/cache /var/www/html/storage/framework/sessions /var/www/html/storage/framework/views
    docker exec onfly_api chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
    docker exec onfly_api chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
    Write-Host "Diretorios criados com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Aviso: Erro ao criar diretorios. Continuando..." -ForegroundColor Yellow
}

# Instalar dependencias do Composer
Write-Host "Instalando dependencias do Composer..." -ForegroundColor Yellow
try {
    docker exec onfly_api composer install --ignore-platform-req=ext-fileinfo --optimize-autoloader
    Write-Host "Dependencias instaladas com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao instalar dependencias. Execute manualmente: docker exec onfly_api composer install --ignore-platform-req=ext-fileinfo --optimize-autoloader" -ForegroundColor Yellow
}

# Gerar chave da aplicacao Laravel
Write-Host "Gerando chave da aplicacao Laravel..." -ForegroundColor Yellow
try {
    docker exec onfly_api php artisan key:generate --force
    Write-Host "Chave da aplicacao gerada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao gerar chave. Execute manualmente: docker exec onfly_api php artisan key:generate --force" -ForegroundColor Yellow
}

# Gerar chave JWT
Write-Host "Gerando chave JWT..." -ForegroundColor Yellow
try {
    docker exec onfly_api php artisan jwt:secret --force
    Write-Host "Chave JWT gerada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao gerar chave JWT. Execute manualmente: docker exec onfly_api php artisan jwt:secret --force" -ForegroundColor Yellow
}

# Aguardar mais um pouco para garantir que a API esta pronta
Write-Host "Aguardando API ficar pronta..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar conectividade com banco de dados
Write-Host "Testando conexao com banco de dados..." -ForegroundColor Yellow
try {
    docker exec onfly_api php artisan migrate:status
    Write-Host "Conexao com banco de dados OK!" -ForegroundColor Green
} catch {
    Write-Host "Aviso: Problemas de conexao com banco. Continuando..." -ForegroundColor Yellow
}

# Limpar e recriar banco de dados
Write-Host "Limpando e recriando banco de dados..." -ForegroundColor Yellow
try {
    docker exec onfly_api php artisan migrate:fresh --force
    Write-Host "Banco de dados limpo e recriado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao limpar banco. Tentando migrations normais..." -ForegroundColor Yellow
    try {
        docker exec onfly_api php artisan migrate --force
        Write-Host "Migrations executadas com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao executar migrations. Execute manualmente: docker exec onfly_api php artisan migrate --force" -ForegroundColor Yellow
    }
}

# Executar seeder para criar usuario admin
Write-Host "Criando usuario admin padrao..." -ForegroundColor Yellow
try {
    docker exec onfly_api php artisan db:seed --class=UserSeeder
    Write-Host "Usuario admin criado com sucesso! (admin@admin.com / admin)" -ForegroundColor Green
} catch {
    Write-Host "Erro ao criar usuario admin. Execute manualmente: docker exec onfly_api php artisan db:seed --class=UserSeeder" -ForegroundColor Yellow
}

# Teste final da API
Write-Host "Testando API..." -ForegroundColor Yellow
try {
    $healthCheck = docker exec onfly_api curl -s http://localhost:8000/api/health 2>$null
    if ($healthCheck) {
        Write-Host "API responde corretamente!" -ForegroundColor Green
    } else {
        Write-Host "Aviso: API pode nao estar respondendo." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Aviso: Nao foi possivel testar a API." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup completo!" -ForegroundColor Green
Write-Host ""
Write-Host "URLs disponiveis:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   API:      http://localhost:8000" -ForegroundColor White
Write-Host "   Nginx:    http://localhost" -ForegroundColor White
Write-Host ""
Write-Host "Credenciais do usuario admin:" -ForegroundColor Cyan
Write-Host "   Email:    admin@admin.com" -ForegroundColor White
Write-Host "   Senha:    admin" -ForegroundColor White
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
Write-Host "Comandos para banco de dados:" -ForegroundColor Cyan
Write-Host "   Limpar banco:       docker exec onfly_api php artisan migrate:fresh --force" -ForegroundColor White
Write-Host "   Recriar admin:      docker exec onfly_api php artisan db:seed --class=UserSeeder" -ForegroundColor White
Write-Host "   Reset completo:     docker exec onfly_api php artisan migrate:fresh --seed --force" -ForegroundColor White
Write-Host ""