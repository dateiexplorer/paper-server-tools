#!/bin/bash -l
# Run this script to restore a server backup.
# It replaces a complete copy of the server instance.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi

current_pwd="$(pwd)"

server="$1"
if [ -z "$server" ]; then
    echo "Please enter the name of the server you want to restore."
    exit
fi

# Check the real path, even if it is a symlink
if ! [ -d $(realpath "$PAPER_BACKUP/$server") ]; then
    echo "No backups existing for this server. Aborting..."
    exit
fi

# This server directory exists.
# Get teh real server name if $server is a symlink
server=$(basename $(realpath "$PAPER_BACKUP/$server"))

# If a server is running or a stop job is running, don't restore any files to
# avoid data corruption.
if [ $(ps ax | grep "SCREEN" | grep "$server" | wc -l) -ne 0 ]; then
    echo "This server is currently running."
    echo "Terminate all coressponding processes before restore data."
    echo "Corresponding processes (uids):"
    for p in $(ps -ef | grep "SCREEN" | grep "$server" | grep -v "grep" \
            | awk '{ print $2 }'); do
        echo "  $p"
    done
fi

# List all available backups
echo "Available backups:"
for b in $(ls "$PAPER_BACKUP/$server"); do
    echo "  $b"
done

# Choose a backup
read -p "Enter a backup version: " version

if ! [ -f "$PAPER_BACKUP/$server/$version" ]; then
    echo "Backup not found. Aborting..."
    exit
fi

# Make dirs if they're not created yet.
mkdir -p "$PAPER_HOME"

echo "Restore $version from server $server..."

# Extract the tar archive and unzip it with gzip
cd "$PAPER_HOME"
tar -xzvf "$PAPER_BACKUP/$server/$version"

echo "Process finished successfully!"
cd "$current_pwd"
