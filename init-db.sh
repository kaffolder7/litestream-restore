#!/bin/sh

# Create data directory
mkdir -p "$(dirname "$DB_PATH")"

if [ -f "$DB_REPLICA_PATH" ]; then
  echo "Found backup database, restoring..."
  if litestream restore -if-replica-exists -v "$DB_REPLICA_PATH" "$DB_PATH"; then
    echo "Database restored successfully"
    chown -R root:root "$DB_PATH"
    chmod 644 "$DB_PATH"
    exit 0
  else
    echo "Database restoration failed"
    exit 1
  fi
else
  echo "No backup database found, initializing new SQLite database"
  sqlite3 "$DB_PATH" "PRAGMA journal_mode=WAL; VACUUM;"
  chown -R root:root "$DB_PATH"
  chmod 644 "$DB_PATH"
  exit 0
fi
