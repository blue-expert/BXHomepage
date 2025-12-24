#!/bin/bash

# Stop on any error
set -e

echo "🚀 Starting deployment..."

# 1. Navigate to the project folder
cd /root/BXHomepage

# 2. Pull the latest code from GitHub
# (This relies on the git credentials you just saved!)
echo "📥 Pulling latest changes..."
git pull origin delete-most-files  # OR 'main' (check which branch you are using!)

# 3. Refresh Secrets (Optional, but good practice)
# echo "🔑 Refreshing secrets..."
# ./refresh_secrets.sh

# 4. Restart Docker
# --build: Rebuilds images if Dockerfile changed
# --remove-orphans: Cleans up containers if you removed them from compose
echo "🐳 Restarting containers..."
docker-compose up -d --build --remove-orphans

echo "✅ Deployment successful!"
