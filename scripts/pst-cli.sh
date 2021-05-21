#!/bin/bash -l

command="$1"

#===============================================================================
# Helper functions needed by one ore more commands
#===============================================================================

# Check requirements
check_requirements() {
    all_requirements_present=true

    list=
    # Add all required programs below
    for requirement in tar gzip curl sed jq java screen; do
        # Test if a command for this requirement is found
        if ! [ -x "$(command -v $requirement)" ]; then
            list="${list}  $requirement\n"
            unset all_requirements_present
        fi
    done

    # Check if requirement is missing (all_requirements_present is unset)
    if [ -z $all_requirements_present ]; then
        echo "Some requirements are missing:"
        echo -e "$list"
        echo "Please install them and rerun the script."
        exit
    fi

    # Check if necessary environment variables are set.
    # If not, run the setup automatically
    if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
        echo "Some environment variables are not set."
        echo "I will setup the variables for you..."
        setup
        echo "Configure the variables as you want, then rerun the script."
        exit
    fi
}

#===============================================================================
# Functions for each command for the paper server tools.
#===============================================================================

# Setup environment variables
setup() {
    # Set environment file
    env_file="$HOME/.profile"

    # Check if $env_file and environment variables already exists.
    if [ -f "$env_file" &> /dev/null ] && [ $(cat "$env_file" \
            | grep -w "PAPER_HOME" | wc -l) -ne 0 ]; then
        echo "PAPER_HOME is already set:"
        echo "  $(cat "$env_file" | grep -w PAPER_HOME | cut -d = -f2)"
        echo "You can change the path by edit this environment variable in $env_file."
    else
        echo "Set PAPER_HOME variable in $env_file:"
        echo "  PAPER_HOME=\"$HOME/Paper/server\""

        # Write to $env_file
        echo "export PAPER_HOME=\"$HOME/Paper/server\"" >> "$env_file"
    fi

    printf "\n"

    # Check if PAPER_BACKUP environment variable is set.
    if [ $(cat $env_file | grep -w "PAPER_BACKUP" | wc -l) -ne 0 ]; then
        echo "PAPER_BACKUP is already set:"
        echo "  $(cat "$env_file" | grep -w "PAPER_BACKUP" | cut -d = -f2)"
        echo "You can change the path by edit this environment variable in $env_file."
    else
        echo "Set PAPER_BACKUP variable in $env_file:"
        echo "  PAPER_BACKUP=\"$HOME/Paper/backups\""

        # Write to $env_file
        echo "export PAPER_BACKUP=\"$HOME/Paper/backups\"" >> "$env_file"
    fi

    # Source the $env_file to apply changes and load environment variables in
    # space.
    printf "\n"
    echo "Source $env_file to load environment variables..."
    source "$env_file"

    echo "You're environment variables are setup!"
}

#===============================================================================

create() {
    # Set server settings
    read -p "Server name: " server_name

    if [ -z $server_name ]; then
        echo "Server name must be set! Aborting..."
        exit
    fi

    # Forbid the `current` server, because this name is used by the toolchain as
    # symlink.
    if [ $server_name = "current" ]; then
        echo "This name is reserved by the toolchain."
        echo "Please choose another server name!"
        exit
    fi

    path="$PAPER_HOME/$server_name"
    if [ -d "$path" ]; then
        echo "This directory already exists!"
        echo "Please remove the directory or enter another server name!"
        exit
    fi

    mkdir -p "$path"
    cd "$path"

    echo "Available server versions:"
    versions=$(curl -s "https://papermc.io/api/v1/paper/" | \
        jq -r '.versions | reverse | @sh')

    for v in $versions; do
        echo "  $(echo "$v" | sed "s/'//g")"
    done

    # Do things in $PAPER_HOME/$server_name/
    read -p "Enter server version: " version

    # Get sepcific server version
    curl -o paper_server.jar \
        "https://papermc.io/api/v1/paper/$version/latest/download"

    # TODO: Make sure that the command executes successfully

    echo "Execute server jar for the first time..."
    java -Xms256M -Xmx496M -jar paper_server.jar

    printf "\n"
    echo "Accepting EULA..."
    sed -i "s/eula=false/eula=true/g" eula.txt
    echo "EULA accepted."

    sed -i "s/level-name=world/level-name=$server_name/g" server.properties

    printf "\n"
    read -p "Server description [A Minecraft Server]: " description
    if [ -n "$description" ]; then
    sed -i "s/motd=A Minecraft Server/motd=$description/g" server.properties
    fi

    read -p "Gamemode [survival]: " c_gamemode
    if [ -n "$c_gamemode" ]; then
    sed -i "s/gamemode=survival/gamemode=$c_gamemode/g" server.properties
    fi

    read -p "Difficulty [normal]: " c_difficulty
    if [ -n "$c_gamemode" ]; then
    sed -i "s/difficulty=easy/difficulty=$c_difficulty/g" server.properties
    else
    sed -i "s/difficulty=easy/difficulty=normal/g" server.properties
    fi

    read -p "Level seed []: " c_level_seed
    if [ -n "$c_level_seed" ]; then
    sed -i "s/level-seed=/level-seed=$c_level_seed/g" server.properties
    fi

    printf "\n"
    echo "Server successfully created."
    echo "Default port is 25565."
}

#===============================================================================

run() {
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
    echo "To minimize the window and let the server run in background, press Ctrl+A then Ctrl+D."
}

#===============================================================================

stop() {
    server="$1"
    if [ -z "$server" ]; then
        echo "Please enter the name of the server you want to stop."
        exit
    fi

    path="$PAPER_HOME/$server"
    if ! [ -e "$path" ]; then
        echo "This server does not exists. Aborting..."
        exit
    fi

    server=$(basename $(realpath "$path"))

    if [ $(ps ax | grep "java" | grep "$server" | wc -l) -eq 0 ]; then
        echo "Server $server is already DOWN! Aborting..."
        exit
    fi

    if [ $(ps ax | grep "SCREEN" | grep "$server-stop" | wc -l) -ne 0 ]; then
        echo "Stop script is already running."
        echo "To access the console type 'screen -r $server-stop'."
        echo "Aborting..."
        exit
    fi

    screen -dmS "$server-stop" sh "$(dirname $(realpath $0))/stopd.sh" "$server" "$2"
    echo "Stop script is running. To view window type 'screen -r $server-stop'."
    echo "To minimize the window and let the script run in background, press Ctrl+A then Ctrl+D."
}

#===============================================================================

backup() {
    server="$1"
    if [ -z "$server" ]; then
        echo "Please enter the name of the server you want to backup."
        exit
    fi

    # Check the real path, even if it is a symlink.
    if ! [ -e "$PAPER_HOME/$server" ]; then
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
        for process in $(ps -ef | grep "SCREEN" | grep "$server" \
                | grep -v "grep" | awk '{ print $2 }'); do
            echo "  $process"
        done
        exit
    fi

    # Get current timestamp as foldername
    timestamp="$(date +"%Y%m%d%H%M")"

    path="$PAPER_BACKUP/$server"

    # Make dirs if they're not created yet.
    mkdir -p "$path"

    echo "Create backup from $server with timestamp $timestamp..."

    # Creates a tar archive and compress it with gzip
    cd "$PAPER_HOME"
    tar -czvpf "$path/$timestamp.tar.gz" "$server"

    echo "Backup successfully created!"
}

#===============================================================================

restore() {
    server="$1"
    if [ -z "$server" ]; then
        echo "Please enter the name of the server you want to restore."
        exit
    fi

    # This server directory exists.
    # Get teh real server name if $server is a symlink
    server=$(basename $(realpath "$PAPER_HOME/$server"))

    # Check the real path, even if it is a symlink
    if ! [ -e "$PAPER_BACKUP/$server" ]; then
        echo "No backups existing for this server. Aborting..."
        exit
    fi

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

    echo "Server successfully restored!"
}

#===============================================================================

list() {
    if ! [ -d "$PAPER_HOME/" ]; then
        echo "No servers available."
        exit
    fi

    # Get all directories, except the `current` symlink directory.
    dir=$(ls "$PAPER_HOME/" | grep -v "current")

    list=
    for entry in $dir; do
        # Check if the neccessary jar file exists.
        if [ -f "$PAPER_HOME/$entry/paper_server.jar" ]; then
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
}

#===============================================================================

current() {
    server="$1"
    path="$PAPER_HOME/$server";

    current="$PAPER_HOME/current"

    if [ -z "$server" ]; then
        echo "Please enter name of the server you want to set as current.";
        exit
    fi

    # Forbid the to symlink the curernt server, because this name is used by the
    # toolchain as symlink.
    if [ $server_name = "current" ]; then
        echo "You're crazy. Do you like recursiveness?"
        echo "Can't symlink the 'current' directory because it's a symlink itself."
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
            # TODO: Stop the current server, if it runs

            # Unlink the previous current server
            unlink "$current"
        fi
    fi

    # Set the selected server as current server
    echo "Set $server as current server..."

    # Create symbolic link to the server
    ln -s "$path" "$current"

    echo "Set $server as current successfully!"
}

#===============================================================================

usage() {
    # Print banner
    echo -e "
                __                 __
______  _______/  |_  ____   ____ |  |   ______
\____ \/  ___/\   __\/  _ \ /  _ \|  |  /  ___/
|  |_> >___ \  |  | (  <_> |  <_> )  |__\___ \\
|   __/____  > |__|  \____/ \____/|____/____  >
|__|       \/                               \/

Version 1.0.0
"

    echo "Justus Röderer <justus.roederer@outlook.com>"
    echo ""
    echo "Usage:"
    echo "  setup                 Setup environment variables"
    echo "  create                Create a new server"
    echo "  list                  List all available servers"
    echo "  run <server>          Run a server"
    echo "  stop <server> [now]   Stop a server"
    echo "  backup <server>       Create a backup from the server"
    echo "  restore <server>      Restore a server from a backup"
    echo "  current <server>      Set the given server as 'current'"
    echo "  help                  Print this help dialog"
}

#===============================================================================
# Main
#===============================================================================

# Always check requirements
set -e

check_requirements

current_pwd="$(pwd)"

case "$command" in
    "setup")
        setup
        ;;
    "create")
        create
        ;;
    "run")
        run "$2"
        ;;
    "stop")
        stop "$2" "$3"
        ;;
    "backup")
        backup "$2"
        ;;
    "restore")
        restore "$2"
        ;;
    "list")
        list
        ;;
    "current")
        current "$2"
        ;;
    *)
        usage
        ;;
esac

cd "$current_pwd"
