#!/bin/bash -l
# Set the selected server as the current server.
# Needed for some tools like the discord bot.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi

current_pwd="$(pwd)"
server="$1"
path="$PAPER_HOME/$server";

current="$PAPER_HOME/current"

if [ -z "$server" ]; then
    echo "Please enter name of the server you want to set as current.";
    exit
fi

if ! [ -e "$path" ]; then
    echo "This server does not exists. Aborting..."
    exit
fi

# Selected server exists

# Check if a current server is already set.
if [ -d "$current" ]; then
    echo "A current server already exists."
    echo "If you continue, the current server stops immediatly to prevent data loss."
    read -p "Would you override the current server? [y/N] " continue

    # If not continue, exit the script
    if ! [[ $continue =~ [yY](es)? ]]; then
        echo "Aborting..."
        exit
    else
        # Stop the current server, if it runs

        # Unlink the previous current server
        unlink "$current"
    fi
fi

# Set the selected server as current server
echo "Set $server as current server..."

# Create symbolic link to the server
ln -s "$path" "$current"

echo "Finished successfully!"
