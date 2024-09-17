# Use Node.js 18 with Alpine as the base image
FROM node:18-alpine

# Install NGINX
RUN apk add --no-cache nginx

# Ensure appropriate permissions for NGINX and application directories
RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs && \
    chown -R nginx:nginx /simple-reactjs-app /var/lib/nginx /etc/nginx && \
    chmod -R 755 /var/lib/nginx

RUN chmod -R 777 /etc/nginx

# Set the working directory for the application
WORKDIR /simple-reactjs-app

# Copy application files
COPY . .

# Install Node.js dependencies, build the React app, and clean up npm cache
RUN npm install && \
    npm run build && \
    npm cache clean --force

# Install Create React App globally
RUN npm install -g create-react-app

# Copy NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 3000
EXPOSE 3000

# Switch to nginx user
USER nginx

# Start both NGINX and the Node.js server
CMD ["sh", "-c", "npm start dev & nginx -g 'daemon off;'"]
