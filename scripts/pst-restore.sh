#! /bin/bash -l
# Run this script to restore a server backup.
# It replaces a complete copy of the server instance.

current_pwd="$(pwd)"

server="$1"
if [ -z "$server" ]; then
    echo "Please enter the name of the server you want to restore."
    exit
fi

if ! [ -d "$PAPER_BACKUP/$server" ]; then
    echo "No backups existing for this server. Aborting..."
    exit
fi

# List all available backups
echo "Available backups:"
for b in $(ls "$PAPER_BACKUP/$server"); do
    echo "  $b"
done

# Choose a backup
read -p "Enter a backup version: " version

if ! [ -d "$PAPER_BACKUP/$server/$version" ]; then
    "Backup not found. Aborting..."
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
