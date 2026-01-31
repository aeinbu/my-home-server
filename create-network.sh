#!/bin/bash

# Create macvlan network
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  --ip-range=192.168.1.128/25 \
  -o parent=enp3s0f1 \
  my-macvlan-network

echo "Network my-macvlan-network created successfully"
