#! /bin/bash -l
# Do not run this script manually.
# Use the pst-stop.sh script instead.

server="$1"

echo "Server $server will shut down in 1 hour."
echo "If you don't want this, kill the job!"

screen -Rd "$server-run" -X stuff "say Server shuts down in 1 hour! $(printf '\r')"
sleep 30m
screen -Rd "$server-run" -X stuff "say Server shuts down in 30 minutes! $(printf '\r')"
sleep 20m
screen -Rd "$server-run" -X stuff "say Server shuts down  in 10 minutes! $(printf '\r')"
sleep 5m
screen -Rd "$server-run" -X stuff "say Server shuts down in 5 minutes! $(printf '\r')"
sleep 3m
screen -Rd "$server-run" -X stuff "say Server shuts down  in 2 minutes! $(printf '\r')"
sleep 1m
screen -Rd "$server-run" -X stuff "say Server shuts down  in 1 minute! $(printf '\r')"
sleep 30s
screen -Rd "$server-run" -X stuff "say Server shuts down  in 30 seconds! $(printf '\r')"
sleep 25s
screen -Rd "$server-run" -X stuff "say Server shuts down in 5 seconds! $(printf '\r')"
sleep 1s
screen -Rd "$server-run" -X stuff "say Server shuts down in 4 seconds! $(printf '\r')"
sleep 1s
screen -Rd "$server-run" -X stuff "say Server shuts down in 3 seconds! $(printf '\r')"
sleep 1s
screen -Rd "$server-run" -X stuff "say Server shuts down in 2 seconds! $(printf '\r')"
sleep 1s
screen -Rd "$server-run" -X stuff "say Server shuts down in 1 second! $(printf '\r')"
sleep 1s
screen -Rd "$server-run" -X stuff "say Bye! $(printf '\r')"
sleep 5s
screen -Rd "$server-run" -X stuff "stop $(printf '\r')"
sleep 5s
echo "Server successfully shuts down."
