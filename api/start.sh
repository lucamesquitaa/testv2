#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting OnFly API..."

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
until php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; do
    echo "Database not ready, waiting 2 seconds..."
    sleep 2
done

echo "✅ Database connection established"

# Run migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# Clear and cache config for better performance
echo "🔧 Optimizing Laravel..."
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache

# Start PHP development server
echo "🌐 Starting PHP server on port 8000..."
php artisan serve --host=0.0.0.0 --port=8000