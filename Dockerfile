ARG VARIANT=debian
ARG ALPINE_VERSION=3.21
ARG DEBIAN_VERSION=bookworm-slim

## Define builders for each variant

FROM alpine:${ALPINE_VERSION} as alpine-builder
# Install wget (needed for fetching Litestream binary) & download latest `litestream` release
RUN apk add --no-cache wget && \
    wget -q https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz -O - | tar -xz

FROM debian:${DEBIAN_VERSION} as debian-builder
# Install wget (needed for fetching Litestream binary) & download latest `litestream` release
RUN apt-get update && \
    apt-get install -y wget && \
    wget -q https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz -O - | tar -xz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Define final images for each variant

FROM alpine:${ALPINE_VERSION} as alpine
# Install sqlite3 and copy `litestream` binary from builder stage
RUN apk add --no-cache sqlite

FROM debian:${DEBIAN_VERSION} as debian
# Install sqlite3 and copy `litestream` binary from builder stage
RUN apt-get update && \
    apt-get install -y sqlite3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Select the appropriate builder and final image based on VARIANT
FROM ${VARIANT}-builder as builder
FROM ${VARIANT} as final

# Copy from builder to final image
COPY --from=builder /litestream /usr/local/bin/

# Ensure `litestream` is executable
RUN chmod +x /usr/local/bin/litestream

# CMD ["sh"]
CMD ["litestream", "restore", "-if-replica-exists"]