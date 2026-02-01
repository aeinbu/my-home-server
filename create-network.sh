#!/bin/bash

# Create macvlan network
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --ip-range=192.168.1.128/25 \
  -o parent=enp3s0f1 \
  my-macvlan-network

docker network create \
  --driver bridge \
  --subnet=172.20.0.0/24 \
  --ip-range=172.20.0.128/25 \
  --gateway=172.20.0.1 \
  my-docker-to-docker-bridge

echo "Networks my-macvlan-network and my-docker-to-docker-bridge created successfully"
