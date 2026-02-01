# NGINX configuration

## Info about the current Setup

This nginx instance provides two virtual hosts:

- **nginx.lab** - Public, unauthenticated home page
- **secure.nginx.lab** - Protected by OAuth2/Keycloak authentication via oauth2-proxy

### Authentication Flow
The `secure.nginx.lab` site uses:
- **oauth2-proxy** for OIDC authentication against Keycloak
- **nginx auth_request** directive to validate every request
- Session cookies for maintaining authenticated state

### Key Features
- Dual-network setup (macvlan for external access, bridge for internal communication)
- Large proxy buffers to handle OIDC response headers
- Automatic redirect to login page on 401 (unauthenticated)
- Proper session cleanup on logout


## Setup instructions for [https://secure.nginx.lab](https://secure.nginx.lab)
This setup requires that keycloak-server is running.

### 1. Seting up a realm and a client in Keycloak
Ensure keycloak is running, then:
1. Log into [keycloak](https://keycloak.lab) to create the `lab-realm`. Then ensure that you are administering this new realm.
2. Go to **Clients** → **Create client**
3. Configure:
   - **Client ID:** `nginx-auth`
      - This should be set to the same value as `--client-id=nginx-auth` in `./docker-compose.yaml`
   - **Client Type:** OpenID Connect
   - **Client authentication:** ON
   - **Valid redirect URIs:** `https://secure.nginx.lab/oauth2/callback`
   - **Web origins:** `https://secure.nginx.lab`
4. Go to **Credentials** tab and copy the **Client Secret**
      - This should be pasted in as the value for `--client-secret=` in `./docker-compose.yaml`

### 2. Generate Cookie Secret
Generate a random value for the cookie secret:
```bash
python3 -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
```
Copy the output, and paste it in as the value for `----cookie-secret=` in `./docker-compose.yaml`

### 4. Restart Services
```bash
cd /home/arjan/containers/nginx
docker compose down
docker compose up -d
```

### 5. Test
Visit https://secure.nginx.lab - you should be redirected to Keycloak for authentication.


## Reloading Configuration
After changing the configuration for nginx, you must apply the changes:

```sh
# if you are inside the container running nginx
nginx -s reload

# if you are on the docker host
docker exec nginx-server nginx -s reload
```
