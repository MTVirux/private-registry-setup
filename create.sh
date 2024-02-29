#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo."
    exit 1
fi

source .env

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

mkdir -p "$HOST_REGISTRY_DATA_DIR"/data

cd "$HOST_REGISTRY_DATA_DIR"

echo "version: '3'

services:
  registry:
    container_name:$REGISTRY_CONTAINER_NAME
    image: registry:2.8.3
    ports:
    - "$HOST_REGISTRY_DATA_DIR:5000"
    environment:
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - $HOST_REGISTRY_DATA_DIR/data:/data" > $HOST_REGISTRY_DATA_DIR/docker-compose.yml

docker-compose up -d
