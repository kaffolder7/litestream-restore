FROM alpine:3.21.2 as builder

# Install wget (needed for fetching Litestream binary) & download latest `litestream` release
RUN apk add --no-cache wget && \
    wget -q https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz -O - | tar -xz

# Final stage (with only sqlite & litestream binary)
FROM alpine:3.21.2

# Install sqlite3 and copy `litestream` binary from builder stage
RUN apk add --no-cache sqlite
COPY --from=builder /litestream /usr/local/bin/

# Ensure `litestream` is executable
RUN chmod +x /usr/local/bin/litestream

CMD ["sh"]
