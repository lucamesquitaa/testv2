# Instruções para instalar PostgreSQL extensions no PHP (Windows)

## Método 1: Via Composer (se estiver usando Laravel Sail/Docker)
Use apenas o Docker para desenvolvimento:

```powershell
# Parar servidor local
# Pressione Ctrl+C no terminal onde php artisan serve está rodando

# Usar apenas Docker
docker compose restart api
docker compose exec api php artisan serve --host=0.0.0.0 --port=8000
```

## Método 2: Instalar extensões no PHP local

### Para XAMPP:
1. Abra o arquivo `php.ini` (normalmente em `C:\xampp\php\php.ini`)
2. Procure e descomente essas linhas:
   ```
   extension=pdo_pgsql
   extension=pgsql
   ```
3. Reinicie o Apache

### Para PHP standalone:
1. Baixe as DLLs do PostgreSQL para PHP:
   - Vá para https://windows.php.net/downloads/pecl/releases/
   - Baixe php_pgsql e php_pdo_pgsql para sua versão do PHP
2. Coloque os arquivos .dll na pasta `ext` do PHP
3. Edite o php.ini e adicione:
   ```
   extension=pgsql
   extension=pdo_pgsql
   ```

### Para verificar se funcionou:
```powershell
php -m | findstr pgsql
```

## Método 3: Usar diferentes portas (Recomendado para desenvolvimento)

Configure o Docker na porta 8001 e o local na 8000:
- Docker API: http://localhost:8001 (com PostgreSQL)
- Local API: http://localhost:8000 (para desenvolvimento rápido, mas sem PostgreSQL)

## Configuração recomendada:

Use o Docker para APIs que precisam de banco de dados e o local apenas para testes rápidos.

```powershell
# Para usar Docker API (com PostgreSQL)
docker compose exec api php artisan tinker

# Para desenvolvimento local (sem PostgreSQL, use SQLite)
php artisan serve
```