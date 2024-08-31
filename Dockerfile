FROM node:18-alpine as builder

WORKDIR /app

COPY . /app

RUN npm install

RUN npm run build

FROM alfabytes/base-laravel:8.2

COPY --from=builder /app /var/www/html

WORKDIR /var/www/html

RUN composer install -v
RUN php artisan config:cache && php artisan config:clear
RUN php artisan storage:link

# Set correct permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod -R 775 storage \
    && chmod -R 775 bootstrap/cache
