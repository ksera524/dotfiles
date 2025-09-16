#!/bin/bash
set -e

echo "🐳 Docker Setup for WSL2"
echo "========================"

# Check if running in WSL2
if ! grep -qi microsoft /proc/version; then
    echo "⚠️  Warning: This script is designed for WSL2 but WSL2 was not detected"
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "✓ Docker is already installed ($(docker --version))"

    # Check if service is running
    if sudo service docker status > /dev/null 2>&1; then
        echo "✓ Docker service is running"
    else
        echo "Starting Docker service..."
        sudo service docker start
        echo "✓ Docker service started"
    fi

    # Check if user is in docker group
    if groups | grep -q docker; then
        echo "✓ User is already in docker group"
    else
        echo "Adding user to docker group..."
        sudo usermod -aG docker $USER
        echo "✓ User added to docker group"
        echo "⚠️  You need to log out and back in for group changes to take effect"
    fi
else
    echo "Installing Docker..."

    # Update package list
    echo "Updating package list..."
    sudo apt update

    # Install Docker and Docker Compose
    echo "Installing docker.io and docker-compose..."
    sudo apt install -y docker.io docker-compose

    # Add user to docker group
    echo "Adding user to docker group..."
    sudo usermod -aG docker $USER

    # Start Docker service
    echo "Starting Docker service..."
    sudo service docker start

    echo ""
    echo "✅ Docker installation complete!"
    echo ""
    echo "📋 Installed versions:"
    docker --version
    docker-compose --version
    echo ""
    echo "⚠️  Important: You need to log out and back in for docker group changes to take effect"
    echo "   Or run: newgrp docker"
fi

# Test Docker installation
echo ""
echo "Testing Docker installation..."
if sudo docker run --rm hello-world > /dev/null 2>&1; then
    echo "✓ Docker is working correctly"
else
    echo "❌ Docker test failed. Please check the installation."
    exit 1
fi

echo ""
echo "🎉 Docker setup complete!"
echo ""
echo "Useful commands:"
echo "  docker ps          - List running containers"
echo "  docker images      - List available images"
echo "  docker-compose up  - Start services defined in docker-compose.yml"