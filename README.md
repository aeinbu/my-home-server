# Arjans lab setup instruction
This was used on Ubuntu 22.04.5 LTS

### *TL;DR*
1. Make all the shell scripts executable
    ```sh
    chmod +x ./create-network.sh
    chmod +x ./create-root-ca.sh
    chmod +x ./create-domain-cert.sh
    chmod +x ./create-service.sh
    ```
2. Create the network used in all the containers
    ```sh
    ./create-network.sh
    ```
3. Optional: Create new `docker-compose.yaml`-files.  
    ```sh
    ./create-service debby debian:latest debby-service
    ```
    This will create a `docker-compose.yaml` file in the `debby` folder, for running the `debby-server` container running the `debian:latest`  
    After creation, modify the `docker-compose.yaml` file
    - You must change the IP and MAC addresses
    - Consider ports, paths, volume names, environment variables etc. for the new service
4. Create self-signed certificates for the services you want to run
    ```sh
    # Create ~/.ssl/rootCA.key and ~/rootCA.pem
    ./create-root-ca.sh

    # Create the cert files for the some.domain.lab domain
    ./create-domain-cert.sh someservice some.domain.lab
    # Create the cert files for the other.domain.lab domain
    ./create-domain-cert.sh someservice other.domain.lab

    # Create the cert files for the thrid.domain.lab domain. Use the `-p` flag to have it ask for a password for the .pfx-file
    ./create-domain-cert.sh someservice third.domain.lab

    ```
    The rootCA will be stored in `~/.ssl/`, and the domain certificates will be stored in `./someservice/certs/`  
5. Optional: See instructions below on how to Trust the self-signed Root CA on your client computers
6. Start containers by running `docker compose up -d` in each service's directory


## Create self-signed certificates
Warning: These script will create certificates with blank passwords.

### Create Root CA
Run the following script
```sh
./create-root-ca.sh
```

The root CA's certificate and keys are now stored in `~/.ssl/` as `rootCA.pem` and `rootCA.key`.

Warning: You should NEVER share `rootCA.key`. It is used to create the domain certificates that will automatically be trusted on your computer(s).

You can safely give anyone access to `rootCA.pem`. It is used to trust the domain certificates you have created.

### Trust the self-signed Root CA
You must configure your client computer(s) to trust the self-signed certificates.

#### Linux
Copy `~/.ssl/rootCA.pem` from the server to your local machine

Run the following commands in the shell (terminal) to trust the certificate on your Linux machine:
```sh
sudo cp rootCA.pem /usr/local/share/ca-certificates/server-rootCA.pem
sudo update-ca-certificates
```

#### Macos
Copy `~/.ssl/rootCA.pem` from the server to `~/.ssl/server-rootCA.pem` on your Mac

Run the following command in the shell (terminal) to trust the certificate on your Mac:
```sh
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/.ssl/server-rootCA.pem
```

#### Windows
Copy `~/.ssl/rootCA.pem` from the server to your local Windows machine

Run the following command in Powershell to trust the certificate on your Windows computer:
```powershell
Import-Certificate -FilePath "C:\path\to\rootCA.pem" -CertStoreLocation Cert:\LocalMachine\Root
```

