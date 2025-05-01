#!/bin/bash
set -euxo pipefail

echo "=== Updating packages and installing prerequisites ==="
apt-get update -y
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

echo "=== Installing Docker ==="
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

echo "=== Enabling and starting Docker ==="
systemctl enable docker
systemctl start docker

echo "=== Creating Docker volume for Nexus data ==="
docker volume create nexus-data

echo "=== Pulling Nexus Docker image ==="
docker pull sonatype/nexus3

echo "=== Running Nexus container ==="
docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v nexus-data:/nexus-data \
  --restart=unless-stopped \
  sonatype/nexus3

echo "=== Nexus installation complete ==="
