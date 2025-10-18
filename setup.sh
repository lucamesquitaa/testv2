#!/bin/bash

echo "🚀 Iniciando setup do OnFly com Docker..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

# Copiar arquivo de ambiente se não existir
if [ ! -f "api/.env" ]; then
    echo "📋 Copiando arquivo de ambiente..."
    cp api/.env.docker api/.env
    echo "✅ Arquivo .env criado"
fi

# Construir e iniciar containers
echo "🏗️  Construindo containers..."
docker-compose up --build -d

echo "⏳ Aguardando containers iniciarem..."
sleep 30

# Instalar dependências do Composer
echo "📦 Instalando dependências do Composer..."
docker-compose exec -T api composer install --no-dev --optimize-autoloader
echo "✅ Dependências instaladas com sucesso!"

# Gerar chave da aplicação Laravel
echo "🔑 Gerando chave da aplicação Laravel..."
docker-compose exec -T api php artisan key:generate

# Executar migrations
echo "🗄️  Executando migrations..."
docker-compose exec -T api php artisan migrate --force

echo ""
echo "🎉 Setup completo!"
echo ""
echo "📍 URLs disponíveis:"
echo "   Frontend: http://localhost:3000"
echo "   API:      http://localhost:8000"
echo "   Nginx:    http://localhost"
echo ""
echo "🔧 Comandos úteis:"
echo "   Ver logs:           docker-compose logs -f"
echo "   Parar containers:   docker-compose down"
echo "   Reiniciar:          docker-compose restart"
echo ""