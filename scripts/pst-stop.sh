#!/bin/bash -l
# Minecraft server save and shutdown.
# Run this script 1 hour before you want shutdown your server.


if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup.sh script before using this script."
    exit
fi

server="$1"
if [ -z "$server" ]; then
    echo "Please enter the name of the server you want to stop."
    exit
fi

path="$PAPER_HOME/$server"
if ! [ -e "$path" ]; then
   echo "This server does not exists."
   exit
fi

server=$(basename $(realpath "$path"))

if [ $(ps ax | grep "java" | grep "$server" | wc -l) -eq 0 ]; then
    echo "Server $server is already DOWN! Aborting..."
    exit
fi

if [ $(ps ax | grep "SCREEN" | grep "$server-stop" | wc -l) -ne 0 ]; then
   echo "Stop script is already running. Aborting..."
   exit
fi

screen -dmS "$server-stop" sh "$(dirname $(realpath $0))/pst-stopd.sh" "$server"
echo "Stop script is running. To view window type 'screen -r $server-stop'."
echo "To minimize the window and let the script run in background, |
press Ctrl+A then Ctrl+D."
