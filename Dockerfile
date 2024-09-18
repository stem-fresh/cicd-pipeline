# Use an official Node.js runtime as a parent image
FROM node:18-alpine as node-build

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the application code
COPY . .

# Build the application
RUN npm run build

# Install NGINX
FROM nginx:alpine

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built application files
COPY --from=node-build /app/build /usr/share/nginx/html

# Expose port 80 and 443
EXPOSE 80 443

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
