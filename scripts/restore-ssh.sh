#!/bin/bash

BACKUP_DIR="$HOME/.ssh-backup"
SSH_DIR="$HOME/.ssh"

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
    echo "No SSH backup found at $BACKUP_DIR/"
    echo "Run backup-ssh.sh on your old system first."
    exit 1
fi

echo "Restoring SSH keys from $BACKUP_DIR to $SSH_DIR..."

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

cp "$BACKUP_DIR/"* "$SSH_DIR/"

for f in "$SSH_DIR"/*; do
    if [[ "$f" == *.pub ]] || [[ "$f" == *known_hosts* ]]; then
        chmod 644 "$f"
    else
        chmod 600 "$f"
    fi
done

echo "Restore complete. SSH keys restored to $SSH_DIR/"
ls -la "$SSH_DIR/"
