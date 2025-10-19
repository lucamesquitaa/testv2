# OnFly Docker Setup Script para Windows

Write-Host "Iniciando setup do OnFly com Docker..." -ForegroundColor Green

# Verificar se Docker esta instalado
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker encontrado: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker command failed"
    }
} catch {
    Write-Host "Docker nao esta instalado ou nao esta rodando. Por favor, instale o Docker Desktop e certifique-se de que esta executando." -ForegroundColor Red
    exit 1
}

# Verificar se Docker Compose esta disponivel
$useDockerCompose = $false
try {
    $composeVersion = docker-compose --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $useDockerCompose = $true
        Write-Host "Docker Compose (v1) encontrado: $composeVersion" -ForegroundColor Green
    } else {
        throw "docker-compose not found"
    }
} catch {
    try {
        $composeVersion = docker compose version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker Compose (v2) encontrado: $composeVersion" -ForegroundColor Green
        } else {
            throw "docker compose not found"
        }
    } catch {
        Write-Host "Docker Compose nao esta instalado." -ForegroundColor Red
        exit 1
    }
}

# Parar containers existentes se estiverem rodando
Write-Host "Parando containers existentes..." -ForegroundColor Yellow
try {
    if ($useDockerCompose) {
        docker-compose down --remove-orphans 2>$null
    } else {
        docker compose down --remove-orphans 2>$null
    }
    Write-Host "Containers parados" -ForegroundColor Green
} catch {
    Write-Host "Nenhum container estava rodando" -ForegroundColor Yellow
}

# Copiar arquivo de ambiente se nao existir
$envPath = "api\.env"
$envDockerPath = "api\.env.docker"

if (-not (Test-Path $envPath)) {
    Write-Host "Copiando arquivo de ambiente..." -ForegroundColor Yellow
    if (Test-Path $envDockerPath) {
        Copy-Item $envDockerPath $envPath
        Write-Host "Arquivo .env criado a partir do .env.docker" -ForegroundColor Green
    } else {
        Write-Host "Arquivo .env.docker nao encontrado! Usando .env.example como base..." -ForegroundColor Yellow
        if (Test-Path "api\.env.example") {
            Copy-Item "api\.env.example" $envPath
            Write-Host "Arquivo .env criado a partir do .env.example" -ForegroundColor Green
        } else {
            Write-Host "Nenhum arquivo de ambiente template encontrado!" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "Arquivo .env ja existe" -ForegroundColor Green
}

# Limpar imagens antigas (opcional)
Write-Host "Limpando imagens antigas..." -ForegroundColor Yellow
try {
    docker image prune -f 2>$null
    Write-Host "Imagens antigas removidas" -ForegroundColor Green
} catch {
    Write-Host "Erro ao limpar imagens antigas, continuando..." -ForegroundColor Yellow
}

# Construir e iniciar containers
Write-Host "Construindo e iniciando containers..." -ForegroundColor Yellow
try {
    if ($useDockerCompose) {
        $result = docker-compose up --build -d 2>&1
    } else {
        $result = docker compose up --build -d 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Containers iniciados com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro ao iniciar containers:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Erro ao executar docker compose:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Aguardar containers iniciarem com verificacao de saude
Write-Host "Aguardando containers iniciarem..." -ForegroundColor Yellow
$maxWait = 180  # 3 minutos
$waited = 0
$step = 10

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $step
    $waited += $step
    
    Write-Host "Verificando status dos containers ($waited/$maxWait segundos)..." -ForegroundColor Yellow
    
    # Verificar se PostgreSQL esta saudavel
    try {
        $pgHealth = docker inspect onfly_postgres --format '{{.State.Health.Status}}' 2>$null
        if ($pgHealth -eq "healthy") {
            Write-Host "PostgreSQL esta saudavel!" -ForegroundColor Green
            break
        } else {
            Write-Host "PostgreSQL status: $pgHealth" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "PostgreSQL ainda nao esta respondendo..." -ForegroundColor Yellow
    }
    
    if ($waited -ge $maxWait) {
        Write-Host "Aviso: Timeout aguardando PostgreSQL. Continuando mesmo assim..." -ForegroundColor Yellow
        break
    }
}

# Aguardar um pouco mais para garantir que todos os servicos estejam prontos
Write-Host "Aguardando servicos estabilizarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Criar diretorios necessarios do Laravel
Write-Host "Criando diretorios necessarios..." -ForegroundColor Yellow
try {
    $dirs = @(
        "/var/www/html/bootstrap/cache",
        "/var/www/html/storage/logs", 
        "/var/www/html/storage/framework/cache",
        "/var/www/html/storage/framework/sessions",
        "/var/www/html/storage/framework/views"
    )
    
    foreach ($dir in $dirs) {
        docker exec onfly_api mkdir -p $dir 2>$null
    }
    
    docker exec onfly_api chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>$null
    docker exec onfly_api chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache 2>$null
    Write-Host "Diretorios criados com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Aviso: Erro ao criar diretorios. Continuando..." -ForegroundColor Yellow
}

# Instalar dependencias do Composer
Write-Host "Instalando dependencias do Composer..." -ForegroundColor Yellow
try {
    $composerResult = docker exec onfly_api composer install --ignore-platform-req=ext-fileinfo --optimize-autoloader --no-interaction 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dependencias instaladas com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Aviso: Problemas com composer install. Output:" -ForegroundColor Yellow
        Write-Host $composerResult -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao instalar dependencias. Execute manualmente: docker exec onfly_api composer install" -ForegroundColor Red
}

# Gerar chave da aplicacao Laravel
Write-Host "Gerando chave da aplicacao Laravel..." -ForegroundColor Yellow
try {
    $keyResult = docker exec onfly_api php artisan key:generate --force 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Chave da aplicacao gerada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Aviso: Problemas ao gerar chave. Output:" -ForegroundColor Yellow
        Write-Host $keyResult -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao gerar chave. Execute manualmente: docker exec onfly_api php artisan key:generate --force" -ForegroundColor Red
}

# Gerar chave JWT
Write-Host "Gerando chave JWT..." -ForegroundColor Yellow
try {
    $jwtResult = docker exec onfly_api php artisan jwt:secret --force 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Chave JWT gerada com sucesso!" -ForegroundColor Green
        # Extrair e mostrar a chave gerada para verificação
        if ($jwtResult -match "\[([^\]]+)\]") {
            $generatedKey = $matches[1]
            Write-Host "Chave gerada: $($generatedKey.Substring(0,20))..." -ForegroundColor Cyan
        }
        
        # Verificar se a chave foi salva no .env
        $envJwtCheck = docker exec onfly_api grep "JWT_SECRET=" /var/www/html/.env 2>$null
        if ($envJwtCheck -and $envJwtCheck -notmatch "JWT_SECRET=$") {
            Write-Host "Confirmado: JWT_SECRET foi salvo no arquivo .env" -ForegroundColor Green
        } else {
            Write-Host "Aviso: JWT_SECRET pode não ter sido salvo corretamente no .env" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Problemas ao gerar chave JWT. Tentando publicar configurações primeiro..." -ForegroundColor Yellow
        docker exec onfly_api php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider" --force 2>$null
        
        # Tentar novamente após publicar configurações
        $jwtResult = docker exec onfly_api php artisan jwt:secret --force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Chave JWT gerada com sucesso após publicar configurações!" -ForegroundColor Green
        } else {
            Write-Host "Erro ao gerar chave JWT:" -ForegroundColor Red
            Write-Host $jwtResult -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Erro ao gerar chave JWT. Execute manualmente: docker exec onfly_api php artisan jwt:secret --force" -ForegroundColor Red
}

# Verificar conectividade com banco de dados
Write-Host "Testando conexao com banco de dados..." -ForegroundColor Yellow
$dbConnected = $false
$maxDbRetries = 10
$dbRetries = 0

while (-not $dbConnected -and $dbRetries -lt $maxDbRetries) {
    try {
        $dbTest = docker exec onfly_api php artisan tinker --execute="DB::connection()->getPdo(); echo 'OK';" 2>&1
        if ($dbTest -like "*OK*") {
            Write-Host "Conexao com banco de dados OK!" -ForegroundColor Green
            $dbConnected = $true
        } else {
            throw "Database not ready"
        }
    } catch {
        $dbRetries++
        Write-Host "Tentativa $dbRetries/$maxDbRetries - Aguardando banco ficar disponivel..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

if (-not $dbConnected) {
    Write-Host "Aviso: Problemas de conexao com banco apos multiplas tentativas. Continuando..." -ForegroundColor Yellow
}

# Limpar e recriar banco de dados
Write-Host "Limpando e recriando banco de dados..." -ForegroundColor Yellow
try {
    $migrateResult = docker exec onfly_api php artisan migrate:fresh --force 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Banco de dados limpo e recriado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro ao limpar banco. Tentando migrations normais..." -ForegroundColor Yellow
        $migrateResult = docker exec onfly_api php artisan migrate --force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Migrations executadas com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "Erro ao executar migrations:" -ForegroundColor Red
            Write-Host $migrateResult -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Erro critico com migrations. Execute manualmente: docker exec onfly_api php artisan migrate --force" -ForegroundColor Red
}

# Executar seeder para criar usuario admin
Write-Host "Criando usuario admin padrao..." -ForegroundColor Yellow
try {
    $seederResult = docker exec onfly_api php artisan db:seed --class=UserSeeder --force 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Usuario admin criado com sucesso! (admin@admin.com / admin)" -ForegroundColor Green
    } else {
        Write-Host "Aviso: Problemas ao criar usuario admin:" -ForegroundColor Yellow
        Write-Host $seederResult -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erro ao criar usuario admin. Execute manualmente: docker exec onfly_api php artisan db:seed --class=UserSeeder" -ForegroundColor Red
}

# Teste final da API
Write-Host "Testando API..." -ForegroundColor Yellow
$apiReady = $false
$apiRetries = 0
$maxApiRetries = 6

while (-not $apiReady -and $apiRetries -lt $maxApiRetries) {
    try {
        $healthCheck = docker exec onfly_api curl -s http://localhost:8000/api/health 2>$null
        if ($healthCheck -and $healthCheck -like "*ok*") {
            Write-Host "API responde corretamente!" -ForegroundColor Green
            $apiReady = $true
        } else {
            throw "API not ready"
        }
    } catch {
        $apiRetries++
        Write-Host "Tentativa $apiRetries/$maxApiRetries - Aguardando API ficar pronta..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}

if (-not $apiReady) {
    Write-Host "Aviso: API pode nao estar respondendo corretamente. Verifique os logs." -ForegroundColor Yellow
}

# Verificar se todos os containers estao rodando
Write-Host "Verificando status final dos containers..." -ForegroundColor Yellow
$containers = @("onfly_postgres", "onfly_api", "onfly_frontend", "onfly_nginx")
$allRunning = $true

foreach ($container in $containers) {
    try {
        $status = docker inspect $container --format '{{.State.Status}}' 2>$null
        if ($status -eq "running") {
            Write-Host "$container : RODANDO" -ForegroundColor Green
        } else {
            Write-Host "$container : $status" -ForegroundColor Yellow
            $allRunning = $false
        }
    } catch {
        Write-Host "$container : NAO ENCONTRADO" -ForegroundColor Red
        $allRunning = $false
    }
}

if ($allRunning) {
    Write-Host "Todos os containers estao rodando!" -ForegroundColor Green
} else {
    Write-Host "Alguns containers podem ter problemas. Verifique os logs." -ForegroundColor Yellow
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