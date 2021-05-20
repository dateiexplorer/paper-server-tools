#!/bin/bash -l
# Show all available servers to manage.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup script before using this script."
    exit
fi

if ! [ -d "$PAPER_HOME/" ]; then
    echo "No servers available."
    exit
fi

dir=$(ls "$PAPER_HOME/")

list=
for entry in $dir; do
    if [ -f "$PAPER_HOME/$entry/paper_server.jar" ]; then
        list="${list} $entry"
    fi
done

if [ -z "$list" ]; then
    echo "No servers available."
    exit
fi

echo "List all available servers:"
for server in $list; do
    printf "  $server "
    if [ $(ps ax | grep "SCREEN" | grep "$server-stop" | wc -l) -ne 0 ]; then
        echo "STOPPING"
    elif [ $(ps ax | grep "SCREEN" | grep "$server-run" | wc -l) -ne 0 ]; then
        echo "UP"
    else
        echo "DOWN"
    fi
done
