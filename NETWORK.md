# Reserved IP and MAC Addresses

## Macvlan Network (my-macvlan-network)

All containers on the lab environment use the `my-macvlan-network` with the following assignments:

| Service | Container | IP Address | MAC Address | Location |
|---------|-----------|-----------|-----------|----------|
| **metamory** | metamory-server | 192.168.1.130 | 02:42:C0:A8:01:82 | `/containers/metamory` |
| **nginx** | nginx-server | 192.168.1.131 | 02:42:C0:A8:01:83 | `/containers/nginx` |
| **oauth2-proxy** | oauth2-proxy | 192.168.1.132 | 02:42:C0:A8:01:84 | `/containers/nginx` |
| **Keycloak** | keycloak-server | 192.168.1.133 | 02:42:C0:A8:01:85 | `/containers/keycloak` |
| **RabbitMQ** | rabbitmq | 192.168.1.134 | 02:42:C0:A8:01:86 | `/containers/rabbitmq` |
| **PostgreSQL** | postgres | 192.168.1.135 | 02:42:C0:A8:01:87 | `/containers/postgres` |
| **pgAdmin** | pgadmin | 192.168.1.136 | 02:42:C0:A8:01:88 | `/containers/postgres` |

## DNS Records

| Hostname | IP Address | Service |
|----------|-----------|---------|
| metamory.lab | 192.168.1.130 | Metamory server |
| nginx.lab | 192.168.1.131 | nginx (public home) |
| secure.nginx.lab | 192.168.1.131 | nginx (protected, auth required) |
| keycloak.lab | 192.168.1.133 | Keycloak identity provider |
| rabbitmq.lab | 192.168.1.134 | RabbitMQ message broker |
| postgres.lab | 192.168.1.135 | PostgreSQL database |
| pgadmin.lab | 192.168.1.136 | pgAdmin web UI |

## SSL Certificates

Generated certificates are stored in each service's `certs/` folder:

- `nginx/certs/nginx.lab.*` - For nginx services
- `keycloak/certs/keycloak.lab.*` - For Keycloak
- `rabbitmq/certs/rabbitmq.lab.*` - For RabbitMQ
- `postgres/certs/postgres.lab.*` - For PostgreSQL

## Notes

- **Base network:** 192.168.1.0/24
- **Gateway:** 192.168.1.1
- **Parent interface:** enp3s0f1
- **Next available IP:** 192.168.1.137
- **MAC pattern:** 02:42:C0:A8:01:XX (where XX = decimal 83-89 currently)

## Adding New Services

When adding a new service:

1. Pick the next available IP (e.g., 192.168.1.137)
2. Calculate next MAC: 02:42:C0:A8:01:89 (hex: 137 = 0x89, next after pgadmin's 0x88)
3. Add to this table
4. Generate certificate: `./create-domain-cert.sh <name> <domain>`
5. Update DNS records
