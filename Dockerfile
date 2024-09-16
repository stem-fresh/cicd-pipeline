FROM node:18-alpine

# Install NGINX
RUN apk add --no-cache nginx

# Create necessary directories and set permissions for NGINX
RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs \
    && chown -R nginx:nginx /var/lib/nginx \
    && chmod -R 755 /var/lib/nginx

# Switch to root for the build process to avoid permission issues
USER root

# Set the working directory
WORKDIR /simple-reactjs-app

# Copy application files
COPY . .

# Install Node.js dependencies and build the React application
RUN npm cache clean --force
RUN npm install
RUN npm run build

# Install Create React App globally
RUN npm install -g create-react-app

# Copy NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set ownership back to nginx user for runtime
RUN chown -R nginx:nginx /simple-reactjs-app

# Expose ports
EXPOSE 3000

# Switch back to nginx user
USER nginx

# Run NGINX and Node.js server
CMD ["sh", "-c", "npm start & nginx -g 'daemon off;'"]
