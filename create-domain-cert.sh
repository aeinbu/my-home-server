#!/bin/bash
#
# Domain Certificate Creator for Ubuntu
# Signs certificates using the Root CA created by create-root-ca.sh
#
set -e

# Configuration
PFX_REQUIRE_PASSWORD=false
while getopts ":p" opt; do
    case "${opt}" in
        p)
            PFX_REQUIRE_PASSWORD=true
            ;;
        *)
            echo "Usage: $0 [-p] <name> [domain] [days]"
            echo "  -p     - Require password for PFX"
            echo "  name   - Folder name (e.g., keycloak, nginx, metamory)"
            echo "  domain - Domain name (default: localhost)"
            echo "  days   - Certificate validity in days (default: 825)"
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

NAME=${1:-}
DOMAIN=${2:-localhost}
DAYS=${3:-825}
SSL_DIR="${HOME}/.ssl"
CA_KEY="${SSL_DIR}/rootCA.key"
CA_CERT="${SSL_DIR}/rootCA.pem"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/${NAME}/certs"

# Check if name parameter is provided
if [[ -z "${NAME}" ]]; then
    echo "Usage: $0 [-p] <name> [domain] [days]"
    echo "  -p     - Require password for PFX"
    echo "  name   - Folder name (e.g., keycloak, nginx, metamory)"
    echo "  domain - Domain name (default: localhost)"
    echo "  days   - Certificate validity in days (default: 825)"
    exit 1
fi

# Check if Root CA exists
if [[ ! -f "${CA_KEY}" || ! -f "${CA_CERT}" ]]; then
    echo "Error: Root CA not found. Run create-root-ca.sh first."
    echo "Expected files: ${CA_KEY} and ${CA_CERT}"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}"

# Clean up any existing files
rm -f ${DOMAIN}.key ${DOMAIN}.crt ${DOMAIN}.pfx ${DOMAIN}.pem ${DOMAIN}.csr v3.ext

echo "Creating certificate for: ${DOMAIN}"

# Create extensions file with SAN
cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
DNS.2 = *.${DOMAIN}
IP.1 = 127.0.0.1
EOF

# Generate private key and CSR
echo "Generating private key and CSR..."
openssl req -new -sha256 -nodes \
    -out ${DOMAIN}.csr \
    -newkey rsa:4096 \
    -keyout ${DOMAIN}.key \
    -subj "/CN=${DOMAIN}"

# Sign with Root CA
echo "Signing certificate with Root CA..."
openssl x509 -req \
    -in ${DOMAIN}.csr \
    -CA "${CA_CERT}" \
    -CAkey "${CA_KEY}" \
    -CAcreateserial \
    -out ${DOMAIN}.crt \
    -days ${DAYS} \
    -sha256 \
    -extfile v3.ext

# Create PKCS12 bundle
PFX_PASSWORD=${PFX_PASSWORD:-}
PFX_PASSOUT="pass:"
if [[ "${PFX_REQUIRE_PASSWORD}" == "true" ]]; then
    if [[ -z "${PFX_PASSWORD}" ]]; then
        echo "Enter password for PFX (will not echo):"
        read -r -s PFX_PASSWORD
        echo ""
        echo "Confirm password:"
        read -r -s PFX_PASSWORD_CONFIRM
        echo ""
        if [[ "${PFX_PASSWORD}" != "${PFX_PASSWORD_CONFIRM}" ]]; then
            echo "Error: Passwords do not match."
            exit 1
        fi
    fi
    PFX_PASSOUT="pass:${PFX_PASSWORD}"
fi

echo "Creating PKCS12 bundle..."
openssl pkcs12 -export \
    -out ${DOMAIN}.pfx \
    -inkey ${DOMAIN}.key \
    -in ${DOMAIN}.crt \
    -passout "${PFX_PASSOUT}"

# Create combined PEM file
cat ${DOMAIN}.crt ${DOMAIN}.key > ${DOMAIN}.pem

# Set permissions
chmod 644 ${DOMAIN}.key ${DOMAIN}.pfx
chmod 644 ${DOMAIN}.crt ${DOMAIN}.pem

# Cleanup temporary files
rm -f ${DOMAIN}.csr v3.ext

echo ""
echo "Done! Certificate files created in: ${OUTPUT_DIR}"
echo "  ${DOMAIN}.key - Private key"
echo "  ${DOMAIN}.crt - Certificate"
if [[ "${PFX_REQUIRE_PASSWORD}" == "true" ]]; then
    echo "  ${DOMAIN}.pfx - PKCS12 bundle (password protected)"
else
    echo "  ${DOMAIN}.pfx - PKCS12 bundle (no password)"
fi
echo "  ${DOMAIN}.pem - Combined cert + key"