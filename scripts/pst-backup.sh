#! /bin/bash -l
# Run this script to backup a server.
# It creates a complete copy of the server instance.

current_pwd="$(pwd)"

server="$1"
if [ -z "$server" ]; then
    echo "Please enter name of server you want to backup."
    exit
fi

if ! [ -d "$PAPER_HOME/server/$server" ]; then
    echo "This server does not exists. Aborting..."
    exit
fi

# Get current timestamp as foldername
timestamp="$(date +"%Y%m%d%H%M")"
path="$PAPER_BACKUP/$server"

# Make dirs if they're not created yet.
mkdir -p "$path"

echo "Create backup from $server with timestamp $timestamp"

# Creates a tar archive and compress it with gzip
cd "$PAPER_HOME/server/"
tar -czvpf "$path/$timestamp.tar.gz" "$server"

echo "Process finished successfully!"
cd "$current_pwd"
