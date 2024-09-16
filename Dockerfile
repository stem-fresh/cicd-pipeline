FROM node:18-alpine

# Install NGINX
RUN apk add --no-cache nginx

# Create necessary directories for NGINX and set appropriate permissions
RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs \
    && chown -R nginx:nginx /var/lib/nginx \
    && chmod -R 755 /var/lib/nginx

# Set the working directory for the application
WORKDIR /simple-reactjs-app

RUN chmod -R 777 /simple-reactjs-app

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

# Ensure ownership and permissions for NGINX and application directories
RUN chown -R nginx:nginx /simple-reactjs-app /var/lib/nginx /etc/nginx

# Expose ports
EXPOSE 3000

# Switch to nginx user
USER nginx

# Run NGINX and the Node.js server
CMD ["sh", "-c", "npm start & nginx -g 'daemon off;'"]

