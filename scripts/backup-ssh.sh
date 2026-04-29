#!/bin/bash

BACKUP_DIR="$HOME/.ssh-backup"

echo "Backing up SSH keys to $BACKUP_DIR..."

mkdir -p "$BACKUP_DIR"

if [ -d "$HOME/.ssh" ] && [ "$(ls -A $HOME/.ssh)" ]; then
    cp -r "$HOME/.ssh/"* "$BACKUP_DIR/"
    echo "Backup complete. Files saved to $BACKUP_DIR/"
    ls -la "$BACKUP_DIR/"
else
    echo "No SSH keys found in ~/.ssh/"
    exit 1
fi
