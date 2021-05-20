#!/bin/bash -l
# Run this script to start and run a server.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi

current_pwd="$(pwd)"
server="$1"
path="$PAPER_HOME/$server";

if [ -z "$server" ]; then
    echo "Please enter name of the server you want to start.";
    exit
fi

if ! [ -e "$path" ]; then
    echo "This server does not exists. Aborting..."
    exit
fi

server=$(basename $(realpath "$path"))

if [ $(ps ax | grep "java" | grep "$server" | wc -l) != 0 ]; then
   echo "Server $server is already UP."
   echo "To access the server console type 'screen -r $server-run'."
   echo "Aborting..."
   exit
fi

cd "$path"
screen -dmS "$server-run" java -jar -Xms2600M -Xmx2600M \
    "$path/paper_server.jar"
echo "Starting minecraft server. To view window type 'screen -r $server-run'."
echo "To minimize the window and let the server run in background, \
press Ctrl+A then Ctrl+D."

cd "$current_pwd"
