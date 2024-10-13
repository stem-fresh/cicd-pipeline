# Base image for Node.js
FROM node:14-alpine

# Create a group and a user with specific IDs
RUN apk add --no-cache shadow \
    && groupadd -g 1024 irys \
    && useradd -u 1025 -r -g irys irys

# Create app directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React app (if applicable)
RUN npm run build

# Change ownership of the app directory
RUN chown -R irys:irys /app

# Switch to the new user
USER 1025

# Expose the application port
EXPOSE 3005

# Start the Node.js application
CMD ["npm", "start"]





