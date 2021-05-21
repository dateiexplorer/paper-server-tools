#!/bin/bash -l
# Do not run this script manually.
# Use the pst-stop.sh script instead.

shutdown() {
    server=$1
    screen -Rd "$server-run" -X stuff "stop $(printf '\r')"
    echo "Server successfully shuts down."
}

shutdown_after_five_seconds() {
    server=$1
    screen -Rd "$server-run" -X stuff "say Server shuts down in 5 seconds! \
    $(printf '\r')"
    sleep 1s
    screen -Rd "$server-run" -X stuff "say Server shuts down in 4 seconds! \
    $(printf '\r')"
    sleep 1s
    screen -Rd "$server-run" -X stuff "say Server shuts down in 3 seconds! \
    $(printf '\r')"
    sleep 1s
    screen -Rd "$server-run" -X stuff "say Server shuts down in 2 seconds! \
    $(printf '\r')"
    sleep 1s
    screen -Rd "$server-run" -X stuff "say Server shuts down in 1 second! \
    $(printf '\r')"
    sleep 1s
    screen -Rd "$server-run" -X stuff "say Bye! $(printf '\r')"
    sleep 5s
    shutdown "$server"
}

shutdown_after_one_hour() {
    server=$1
    screen -Rd "$server-run" -X stuff "say Server shuts down in 1 hour! \
    $(printf '\r')"
    sleep 30m
    screen -Rd "$server-run" -X stuff "say Server shuts down in 30 minutes! \
    $(printf '\r')"
    sleep 20m
    screen -Rd "$server-run" -X stuff "say Server shuts down in 10 minutes! \
    $(printf '\r')"
    sleep 5m
    screen -Rd "$server-run" -X stuff "say Server shuts down in 5 minutes! \
    $(printf '\r')"
    sleep 3m
    screen -Rd "$server-run" -X stuff "say Server shuts down in 2 minutes! \
    $(printf '\r')"
    sleep 1m
    screen -Rd "$server-run" -X stuff "say Server shuts down in 1 minute! \
    $(printf '\r')"
    sleep 30s
    screen -Rd "$server-run" -X stuff "say Server shuts down in 30 seconds! \
    $(printf '\r')"
    sleep 25s
    shutdown_after_five_seconds "$server"
}

server="$1"
option="$2"

case "$option" in
    "now")
        shutdown_after_five_seconds "$server"
        ;;
    *)
        echo "Server $server will shut down in 1 hour."
        echo "If you don't want this, kill the job!"
        shutdown_after_one_hour "$server"
        ;;
esac


