#!/bin/bash
#
# Service Scaffolder for Docker Compose
# Creates a new service folder with docker-compose.yaml template
#
set -e

# Configuration
NAME=${1:-}
IMAGE_NAME=${2:-${NAME}:latest}
CONTAINER_NAME=${3:-${NAME}}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="${SCRIPT_DIR}/${NAME}"

# Check if name parameter is provided
if [[ -z "${NAME}" ]]; then
    echo "Usage: $0 <name> [image] [container-name]"
    echo "  name           - Service name (e.g., postgres, redis, rabbitmq)"
    echo "  image          - Docker image (default: <name>:latest)"
    echo "  container-name - Container name (default: <name>)"
    exit 1
fi

# Check if service directory already exists
if [[ -d "${SERVICE_DIR}" ]]; then
    echo "Error: Directory '${NAME}' already exists."
    echo "Remove it first or choose a different name."
    exit 1
fi

# Create service directory structure
echo "Creating service directory: ${SERVICE_DIR}"
mkdir -p "${SERVICE_DIR}"
mkdir -p "${SERVICE_DIR}/certs"
mkdir -p "${SERVICE_DIR}/config"
mkdir -p "${SERVICE_DIR}/data"

# Create docker-compose.yaml
cat > "${SERVICE_DIR}/docker-compose.yaml" << EOF
services:
  ${NAME}:
    image: ${IMAGE_NAME}
    container_name: ${CONTAINER_NAME}
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./config:/config:ro
      - ./certs:/etc/certs:ro
      - ${NAME}-data:/data
    environment:
      - TZ=Europe/Oslo
    networks:
      my-macvlan-network:
        ipv4_address: #REPLACE_THIS_WITH_CORRECT_IP_ADDRESS 192.168.1.131
    mac_address: #REPLACE_THIS_WITH_CORRECT_MAC_ADDRESS 02:42:C0:A8:01:83

networks:
  my-macvlan-network:
    external: true

volumes:
  ${NAME}-data:
    name: ${NAME}-data
EOF

# Create .gitkeep files to preserve empty directories
touch "${SERVICE_DIR}/certs/.gitkeep"
touch "${SERVICE_DIR}/config/.gitkeep"
touch "${SERVICE_DIR}/data/.gitkeep"

echo ""
echo "Done! Service scaffolded in: ${SERVICE_DIR}"
echo ""
echo "Created structure:"
echo "  ${NAME}/"
echo "  ├── docker-compose.yaml"
echo "  ├── certs/"
echo "  ├── config/"
echo "  └── data/"
echo ""
echo "Next steps:"
echo "  1. Edit docker-compose.yaml to configure the service"
echo "  2. Add configuration files to config/"
echo "  3. Run: cd ${NAME} && docker compose up -d"
