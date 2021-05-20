#!/bin/bash -l
# Run this script to backup a server.
# It creates a complete copy of the server instance.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi

current_pwd="$(pwd)"

server="$1"
if [ -z "$server" ]; then
    echo "Please enter the name of the server you want to backup."
    exit
fi

# Check the real path, even if it is a symlink.
if ! [ -d $(realpath "$PAPER_HOME/$server") ]; then
    echo "This server does not exists. Aborting..."
    exit
fi

# The server directory exists.
# Get the real server name if $server is a symlink.
server=$(basename $(realpath "$PAPER_HOME/$server"))

# If a server is running or a stop job is running, don't backup any files to
# avoid data corruption.
if [ $(ps ax | grep "SCREEN" | grep "$server" | wc -l) -ne 0 ]; then
    echo "This server is currently running."
    echo "Terminate all coressponding processes before backup data."
    echo "Corresponding processes (uids):"
    for p in $(ps -ef | grep "SCREEN" | grep "$server" | grep -v "grep" \
            | awk '{ print $2 }'); do
        echo "  $p"
    done
fi

# Get current timestamp as foldername
timestamp="$(date +"%Y%m%d%H%M")"

path=$("$PAPER_BACKUP/$server")

# Make dirs if they're not created yet.
mkdir -p "$path"

echo "Create backup from $server with timestamp $timestamp..."

# Creates a tar archive and compress it with gzip
cd "$PAPER_HOME"
tar -czvpf "$path/$timestamp.tar.gz" "$server"

echo "Process finished successfully!"
cd "$current_pwd"
