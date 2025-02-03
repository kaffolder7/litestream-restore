ARG VARIANT=alpine
ARG ALPINE_VERSION=3.21
ARG DEBIAN_VERSION=bookworm-slim

## Use the appropriate base image based on VARIANT
FROM ${VARIANT}-builder as builder

# Install wget (needed for fetching Litestream binary) & download latest `litestream` release

FROM alpine:${ALPINE_VERSION} as alpine-builder
RUN apk add --no-cache wget && \
    wget -q https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz -O - | tar -xz

FROM debian:${DEBIAN_VERSION} as debian-builder
RUN apt-get update && \
    apt-get install -y wget && \
    wget -q https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz -O - | tar -xz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Final stage
FROM ${VARIANT} as final

## Set the base image based on variant (final stage with only sqlite & litestream binary)

# Install sqlite3 and copy `litestream` binary from builder stage

FROM alpine:${ALPINE_VERSION} as alpine
RUN apk add --no-cache sqlite

FROM debian:${DEBIAN_VERSION} as debian
RUN apt-get update && \
    apt-get install -y sqlite3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy from appropriate builder
COPY --from=builder /litestream /usr/local/bin/

# Ensure `litestream` is executable
RUN chmod +x /usr/local/bin/litestream

# CMD ["sh"]
CMD ["litestream", "restore", "-if-replica-exists"]