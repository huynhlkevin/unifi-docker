FROM ubuntu:22.04 AS base

LABEL version="0.3.1"

ARG UNIFI=https://dl.ui.com/unifi/9.0.108/unifi_sysvinit_all.deb
ARG UNIFI_SHA256=a7eb785bc991f82b6649766ac693f5539e621e12b3eec5dc2f73eefb4a5e36b5

FROM base AS mongodb
RUN \
  apt-get update && apt-get install -y gnupg curl && \
  curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

FROM mongodb AS unifi
VOLUME [ "/usr/lib/unifi/data" ]
ADD --checksum=sha256:${UNIFI_SHA256} ${UNIFI} /tmp/unifi.deb
RUN apt-get update && apt-get install -y /tmp/unifi.deb
COPY ./system.properties /usr/lib/unifi/data
COPY --chmod=755 ./unifi /usr/bin

FROM unifi AS cleanup
RUN \
  apt-get remove -y gnupg && apt-get autoremove -y && \
  rm /usr/share/keyrings/mongodb-server-7.0.gpg /etc/apt/sources.list.d/mongodb-org-7.0.list /tmp/unifi.deb && \
  rm -r /var/lib/apt/lists

# Used for STUN.
EXPOSE 3478/udp
# Used for device and application communication.
EXPOSE 8080/tcp 
# Used for application GUI/API as seen in a web browser.
EXPOSE 8443/tcp
# Used for HTTP portal redirection.
EXPOSE 8880/tcp
# Used for HTTPS portal redirection.
EXPOSE 8843/tcp
# Used for UniFi mobile speed test.
EXPOSE 6789/tcp
# Used for device discovery.
EXPOSE 10001/udp

HEALTHCHECK --start-period=1m CMD [ "/bin/bash", "-c", "curl --head --silent --fail localhost:8080 || exit 1" ]

USER unifi
CMD [ "unifi" ]