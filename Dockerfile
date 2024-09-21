# Use an official Node.js runtime as a parent image
FROM node:18-alpine as node-build

# Create a non-root user and group with a specific numeric UID and GID
RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Install dependencies as root
COPY package*.json ./
USER root
RUN npm install

# Copy the application code
COPY . .

# Build the application
RUN npm run build

# Use an official NGINX runtime as a base image for serving the app
FROM nginx:alpine

# Create a non-root user and group with a specific numeric UID and GID
RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

# Set the permissions for the nginx directory to allow non-root usage
RUN chown -R 1001:1001 /var/cache/nginx /var/run /var/log/nginx /etc/nginx /usr/share/nginx/html

# Switch to the non-root user by UID
USER 1001

# Copy the NGINX main configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the server block configuration to /etc/nginx/conf.d/
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy the built application files
COPY --from=node-build /app/build /usr/share/nginx/html

# Expose port 80 and 443
EXPOSE 8080 8443

# Start NGINX as a non-root user
CMD ["nginx", "-g", "daemon off;"]
