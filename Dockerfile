# Use an official Node.js runtime as a parent image
FROM node:18-alpine as node-build

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Install dependencies as root
COPY package*.json ./
USER root
RUN npm install

# Switch back to the non-root user
USER appuser

# Copy the application code
COPY . .

# Build the application
RUN npm run build

# Use an official NGINX runtime as a base image for serving the app
FROM nginx:alpine

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the permissions for the nginx directory to allow non-root usage
RUN chown -R appuser:appgroup /var/cache/nginx /var/run /var/log/nginx

# Switch to the non-root user
USER appuser

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built application files
COPY --from=node-build /app/build /usr/share/nginx/html

# Expose port 80 and 443
EXPOSE 80 443

# Start NGINX as a non-root user
CMD ["nginx", "-g", "daemon off;"]
