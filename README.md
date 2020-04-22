# VAULT DB Showcase

This showcase is intended for setting up a postgres database with direct HashiCorp Vault integration. It can be used
for local testing and exploration of the concept. 

Target is to provide:
- An admin role to manage the database/schema
- An application role to access and change data
- An read role to only access data

## Usage

1. Generate rsa keys for psql db
   - [Server Cert] docker/postgres/config/postgres_server.pem
   - [Private Key] docker/postgres/config/postgres_server-key.pem
1. Use docker compose to setup the docker containers. [docker-compose](./docker/docker-compose.yml)
   - start in [docker](./docker) directory
1. Initialize vault.
   - Via ui http://localhost:8200/
   - Or CLI
1. Perform login to vault with root token.
1. Execute terraform apply to create
   - postgres database objects
   - vault secret engine for database
1. Run the test script to verify the setup.

## Attention!
Following points are only used, because it is a local demo showcase:
- Postgres containers are using simple unsecured credentials
- Vault root token would never be used for general vault access
- Vault server uses http instead of https

## TODO
- extract terraform modules