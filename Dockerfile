FROM node:18-alpine

# Create a group and a user with specific IDs
RUN groupadd -g 1024 irys && useradd -u 1025 -r -g irys irys

# Set the working directory
WORKDIR /simple-reactjs-app

# Copy application files
COPY . .

# Clean npm cache and install dependencies
RUN npm cache clean --force && npm install && npm run build && npm install -g create-react-app

# Change ownership of the working directory to the new user
RUN chown -R irys:irys /simple-reactjs-app

# Switch to the non-root user
USER irys

# Expose the port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
