# UniFi Network Server Docker
Unifi Network Server packaged into a Docker container for both amd64 and arm64.

## Create and start containers

### MongoDB 7.0.16 compatible architectures
docker compose --profile=production up -d

### ARMv8 (Raspberry Pi 4 is not compatible with MongoDB 7.0.16)
docker compose --profile=production --env-file ARMv8.env up -d

## Stop and remove containers
docker compose down

The volumes created by the MongoDB container are not automatically removed.