# Use Node.js version 20+ as the base image
FROM node:20

# Create 'irysui' user and group
RUN groupadd -g 1024 irysui && useradd -u 1025 -r -g irysui irysui

# Install system dependencies
RUN apt-get update && apt-get install -y vim git

# Install pnpm using the specified command
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

# Set the working directory inside the container
WORKDIR /app


# Install dependencies using pnpm
RUN pnpm install

COPY . /app

# Build the application
RUN pnpm run build

# Expose port 3000 for external access
EXPOSE 3000

CMD ["pnpm", "run", "dev"]  # For development mode
