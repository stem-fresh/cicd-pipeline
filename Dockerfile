# Use Node.js 18 with Alpine as the base image
FROM node:18-alpine

# Install NGINX and Certbot
RUN apk add --no-cache nginx certbot certbot-nginx supervisor

# Set the working directory for the application
WORKDIR /simple-reactjs-app

# Copy application files
COPY . .

# Install Node.js dependencies, build the React app, and clean up npm cache
RUN npm install && \
    npm run build && \
    npm cache clean --force

# Copy NGINX configuration (updated for HTTP and HTTPS)
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure appropriate permissions for NGINX and application directories
RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs /var/www/certbot && \
    chown -R nginx:nginx /simple-reactjs-app /var/lib/nginx /etc/nginx /var/www/certbot && \
    chmod -R 755 /var/lib/nginx && \
    chmod -R 755 /etc/nginx

# Supervisor configuration for managing NGINX and Certbot together
COPY supervisord.conf /etc/supervisord.conf

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Add environment variables for domain and email used in SSL certificates
ENV DOMAIN_NAME=yourdomain.com
ENV EMAIL=your-email@example.com

# Use root user to run NGINX and Certbot initially
USER root

# Start NGINX and Certbot using Supervisor to handle both
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
