#!/bin/bash -l
# Set the selected server as the current server.
# Needed for some tools like the discord bot.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi
