#! /bin/bash
# Show all available servers to manage.

if ! [ -d "$PAPER_HOME/" ]; then
    echo "You hav'nt any server yet."
    exit
fi

list=$(ls "$PAPER_HOME/")
if [ -z "$list" ]; then
    echo "No servers available."
    exit
fi

echo "List all available servers:"
for server in $list; do
    printf "    $server "
    if [ $(ps ax | grep "SCREEN" | grep "$server-stop" | wc -l) -ne 0 ]; then
        echo "STOPPING"
    elif [ $(ps ax | grep "SCREEN" | grep "$server-run" | wc -l) -ne 0 ]; then
	echo "UP"
    else
	echo "DOWN"
    fi
done
