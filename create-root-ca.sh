#!/bin/bash
#
# Create Self-Signed Root CA for Ubuntu
#
set -e

SSL_DIR="${HOME}/.ssl"
CA_KEY="${SSL_DIR}/rootCA.key"
CA_CERT="${SSL_DIR}/rootCA.pem"

mkdir -p "${SSL_DIR}"

# Step 1: Create self-signed Root CA
echo "Creating Root CA..."
openssl genrsa -out "${CA_KEY}" 4096
openssl req -x509 -new -nodes \
    -key "${CA_KEY}" \
    -sha256 \
    -days 3650 \
    -out "${CA_CERT}" \
    -subj "/C=NO/ST=Norway/L=Oslo/O=Home Lab/CN=Home Root CA"

# Step 2: Trust the Root CA on Ubuntu
echo "Adding Root CA to Ubuntu trust store (requires sudo)..."
sudo cp "${CA_CERT}" /usr/local/share/ca-certificates/rootCA.crt
sudo update-ca-certificates

# Secure the private key
chmod 600 "${CA_KEY}"
chmod 644 "${CA_CERT}"

echo ""
echo "Root CA created successfully!"
echo "  Private Key: ${CA_KEY}"
echo "  Certificate: ${CA_CERT}"
echo ""
echo "The CA is now trusted system-wide on this Ubuntu machine."