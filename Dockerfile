#
# Aerospike Server Dockerfile
#
# http://github.com/aerospike/aerospike-server.docker
#

FROM debian:7

ENV AEROSPIKE_VERSION 3.5.4
ENV AEROSPIKE_SHA256 80c23ea858278419297c51d8fd924ac64d7b62684b24334440c16725ba856e45 

# Install Aerospike
RUN \
  apt-get update -y \
  && apt-get install -y wget logrotate ca-certificates lua5.2 \
  && wget "https://www.aerospike.com/artifacts/aerospike-server-community/${AEROSPIKE_VERSION}/aerospike-server-community-${AEROSPIKE_VERSION}-debian7.tgz" -O aerospike-server.tgz \
  && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
  && dpkg -i aerospike/aerospike-server-*.deb \
  && apt-get purge -y --auto-remove wget ca-certificates \
  && rm -rf aerospike-server.tgz aerospike /var/lib/apt/lists/*

# Add the Aerospike configuration specific to this dockerfile
ADD etc/aerospike/aerospike.conf.template /etc/aerospike/aerospike.conf.template
ADD usr/local/bin/templater.lua /usr/local/bin/templater.lua
ADD usr/local/share/lua/5.2/fwwrt/simplelp.lua /usr/local/share/lua/5.2/fwwrt/simplelp.lua
ADD aerospike-autoconfig /aerospike-autoconfig

# Mount the Aerospike data directory
VOLUME ["/storage/data"]
VOLUME ["/storage/logs"]

# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# Execute the run script in foreground mode

CMD ["/aerospike-autoconfig"]
