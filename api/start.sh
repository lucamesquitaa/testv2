#!/bin/bash
set -e

echo "🚀 Starting Laravel API initialization..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until php -r "try { new PDO('pgsql:host=postgres;port=5432;dbname=onfly_db', 'onfly_user', 'onfly_password'); echo 'Database connected successfully'; } catch (Exception \$e) { echo 'Database connection failed: ' . \$e->getMessage(); exit(1); }"
do
  echo "🔄 Database is unavailable - sleeping..."
  sleep 2
done

echo "✅ Database is ready!"

# Install/update composer dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader

# Generate app key if not exists
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:your-app-key-here" ]; then
    echo "🔑 Generating application key..."
    php artisan key:generate --force
fi

# Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# Clear and cache config
echo "⚙️ Optimizing application..."
php artisan config:cache
php artisan route:cache

echo "🎉 Laravel API initialization completed!"

# Start the server
echo "🌐 Starting Laravel development server..."
exec php artisan serve --host=0.0.0.0 --port=8000