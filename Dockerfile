FROM node:18-alpine

# Install NGINX
RUN apk add --no-cache nginx

RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs \
    && chown -R nginx:nginx /var/lib/nginx \
    && chmod -R 755 /var/lib/nginx

# Run Nginx as the 'nginx' user
USER nginx

# Set the working directory
WORKDIR /simple-reactjs-app

# Copy application files
COPY . .

# Install Node.js dependencies and build the React application
RUN npm cache clean --force
RUN npm install && npm run build && npm install -g create-react-app

# Copy NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports

EXPOSE 3000

# Run NGINX and Node.js server
CMD ["sh", "-c", "npm start & nginx -g 'daemon off;'"]
