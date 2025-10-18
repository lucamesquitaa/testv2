# Use PHP 8.2 with FPM
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    nginx \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies without the project files first
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Copy the rest of the application
COPY . .

# Copy and make start script executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create required directories before composer dump-autoload
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views

# Run composer install again to ensure everything is set up correctly
RUN composer install --no-dev --optimize-autoloader

# Generate optimized autoloader
RUN composer dump-autoload --optimize

# Verify vendor directory exists
RUN ls -la /var/www/html/vendor || echo "Warning: vendor directory not found"

# Change ownership of storage and bootstrap/cache directories
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port 8000
EXPOSE 8000

# Start the application
CMD ["/start.sh"]