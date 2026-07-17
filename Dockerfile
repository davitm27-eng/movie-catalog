# Use official PHP 8.4 image with Apache
FROM php:8.4-apache

# Install system dependencies & PHP extensions needed for Symfony
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev \
    && docker-php-ext-install intl opcache zip pdo pdo_mysql

# Configure Apache Document Root to point to Symfony's public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache rewrite module for Symfony routing
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
WORKDIR /var/www/html
COPY . .

# Set environment to production
ENV APP_ENV=prod

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set correct permissions for Symfony cache and logs
RUN chown -R www-data:www-data /var/www/html/var

EXPOSE 80