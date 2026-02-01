# Reserved IP and MAC Addresses

## Macvlan Network (my-macvlan-network)

All containers on the lab environment use the `my-macvlan-network` with the following assignments:

| Service | Container | IP Address | MAC Address | Location |
|---------|-----------|-----------|-----------|----------|
| **metamory** | metamory-server | 192.168.1.130 | 02:42:C0:A8:01:82 | `/containers/metamory` |
| **nginx** | nginx-server | 192.168.1.131 | 02:42:C0:A8:01:83 | `/containers/nginx` |
| **oauth2-proxy** | oauth2-proxy | 192.168.1.132 | 02:42:C0:A8:01:84 | `/containers/nginx` |
| **Keycloak** | keycloak-server | 192.168.1.133 | 02:42:C0:A8:01:85 | `/containers/keycloak` |

## DNS Records

| Hostname | IP Address | Service |
|----------|-----------|---------|
| metamory.lab | 192.168.1.130 | Metamory server |
| nginx.lab | 192.168.1.131 | nginx (public home) |
| secure.nginx.lab | 192.168.1.131 | nginx (protected, auth required) |
| keycloak.lab | 192.168.1.133 | Keycloak identity provider |

## SSL Certificates

Generated certificates are stored in each service's `certs/` folder:

- `nginx/certs/nginx.lab.*` - For nginx services
- `keycloak/certs/keycloak.lab.*` - For Keycloak

## Notes

- **Base network:** 192.168.1.0/24
- **Gateway:** 192.168.1.1
- **Parent interface:** enp3s0f1
- **Next available IP:** 192.168.1.135
- **MAC pattern:** 02:42:C0:A8:01:XX (where XX = decimal 83-86 currently)

## Adding New Services

When adding a new service:

1. Pick the next available IP (e.g., 192.168.1.135)
2. Calculate next MAC: 02:42:C0:A8:01:87 (hex: 135 = 0x87)
3. Add to this table
4. Generate certificate: `./create-domain-cert.sh <name> <domain>`
5. Update DNS records
