#!/bin/sh

#
# Install homebridge using Docker
#

set -ue

HOMEBRIDGE_PATH="${1:-${HOME}/homebridge}"

# Create docker-compose.yml
mkdir -p "${HOMEBRIDGE_PATH}"/config
cat > "${HOMEBRIDGE_PATH}"/docker-compose.yml <<EOF
version: '2'
services:
  homebridge:
    image: oznu/homebridge:latest
    container_name: homebridge
    restart: unless-stopped
    network_mode: host
    environment:
      - TZ=America/Los_Angeles
      - PGID=1000
      - PUID=1000
    volumes:
      - ${HOMEBRIDGE_PATH}/config:/homebridge
EOF

# Bootstrap and start homebridge
echo "Updating docker images"
docker compose -f "${HOMEBRIDGE_PATH}"/docker-compose.yml pull homebridge

echo "Starting Homebridge"
docker compose -f "${HOMEBRIDGE_PATH}"/docker-compose.yml up homebridge -d

echo "Waiting for Homebridge to start..."
until $(curl --output /dev/null --silent --head --fail http://localhost:8581); do
    printf '.'
    sleep 5
done

echo "Homebridge install complete"
echo "Access homebridge UI:"
IP=$(hostname -I)
for ip in $IP; do
    if "$ip" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "http://$ip:8581"
    else
        echo "http://[$ip]:8581"
    fi
done
