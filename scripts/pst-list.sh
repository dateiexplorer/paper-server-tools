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

# Get all directories, except the `current` symlink directory.
dir=$(ls "$PAPER_HOME/" | grep -v "current")

list=
for entry in $dir; do
    # Check if the neccessary jar file exists.
    if [ -f "$PAPER_HOME/$entry/paper_server.jar" ] then
        list="${list} $entry"
    fi
done

if [ -z "$list" ]; then
    echo "No servers available."
    exit
fi

# Check if `current` is a symlink and the directory behind it exists.
if [ -L "$PAPER_HOME/current" ] && [ -e "$PAPER_HOME/current" ]; then
    # Get the basename from the server behind the symblink.
    current=$(basename $(realpath "$PAPER_HOME/current"))
fi

echo "The current server ist marked with =>."
echo "List all available servers:"
for server in $list; do
    # Check if the `current` symlink exists and equals the current server.
    if [ -n $current ] && [ "$server" = "$current" ]; then
        printf "=> "
    else
        printf "   "
    fi

    printf "$server "
    if [ $(ps ax | grep "SCREEN" | grep "$server-stop" | wc -l) -ne 0 ]; then
        printf "STOPPING"
    elif [ $(ps ax | grep "SCREEN" | grep "$server-run" | wc -l) -ne 0 ]; then
        printf "UP"
    else
        printf "DOWN"
    fi

    printf "\n"
done
