# OnFly Docker Setup

Este setup Docker inclui:
- **Frontend**: Vue.js com Vite (porta 3000)
- **API**: Laravel (porta 8000)
- **Database**: PostgreSQL (porta 5432)
- **Nginx**: Proxy reverso (porta 80) - opcional

## Pré-requisitos

- Docker
- Docker Compose

## Como usar

### 1. Preparar o ambiente

```bash
# Copiar o arquivo de ambiente para a API
cp api/.env.docker api/.env

# IMPORTANTE: Configurar cache driver
# Para desenvolvimento local, recomenda-se usar file cache:
# Edite api/.env e defina: CACHE_STORE=file
# Para produção com cache database, certifique-se de executar: php artisan cache:table && php artisan migrate

# Gerar chave da aplicação Laravel (será feito automaticamente no container)
```

### 2. Inicializar os containers

```bash
# Construir e iniciar todos os serviços
docker-compose up --build

# Ou executar em background
docker-compose up -d --build
```

### 3. Acessar as aplicações

- **Frontend Vue.js**: http://localhost:3000
- **API Laravel**: http://localhost:8000
- **Nginx (proxy)**: http://localhost (opcional)
- **PostgreSQL**: localhost:5432

### 4. Comandos úteis

```bash
# Ver logs dos containers
docker-compose logs -f

# Executar comandos no container da API
docker-compose exec api php artisan migrate
docker-compose exec api php artisan tinker

# Executar comandos no container do frontend
docker-compose exec frontend npm install
docker-compose exec frontend npm run build

# Parar os containers
docker-compose down

# Parar e remover volumes (cuidado: remove dados do banco!)
docker-compose down -v
```

### 5. Estrutura dos serviços

#### PostgreSQL
- **Database**: onfly_db
- **User**: onfly_user
- **Password**: onfly_password
- **Port**: 5432

#### Laravel API
- Configurado para usar PostgreSQL
- Migrations executadas automaticamente
- Composer install executado na inicialização

#### Vue.js Frontend
- Servidor de desenvolvimento do Vite
- Hot reload habilitado
- Node.js 22

## Configurações importantes

### API (.env)
As variáveis de ambiente estão configuradas no `docker-compose.yml` e no arquivo `.env.docker`. 
Principais configurações:
- `DB_HOST=postgres` (nome do serviço Docker)
- `DB_CONNECTION=pgsql`
- Outras configurações de banco conforme o PostgreSQL

### Frontend
Configure a URL da API no arquivo de ambiente ou no Vite config:
```javascript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': 'http://api:8000'
    }
  }
})
```

## Problemas comuns

1. **Porta já em uso**: Altere as portas no `docker-compose.yml`
2. **Permissões**: Execute `docker-compose exec api chown -R www-data:www-data storage bootstrap/cache`
3. **Chave da aplicação**: Execute `docker-compose exec api php artisan key:generate`

## Desenvolvimento

Para desenvolvimento, você pode:
1. Usar apenas os containers necessários: `docker-compose up postgres`
2. Executar API e Frontend localmente apontando para o PostgreSQL do Docker
3. Montar volumes para hot reload (já configurado)

## Produção

Para produção, considere:
1. Usar imagens otimizadas (multi-stage builds)
2. Configurar HTTPS no Nginx
3. Usar variáveis de ambiente seguras
4. Configurar backup do PostgreSQL