# paper-server-tools

Collection of scripts to manage multiple Paper minecraft servers from command 
line.

# What doesn't work (yet)

* Stop a minecraft server immediatly with a script (use the ```/stop```-command
  in your minecraft server session to terminate the server)

# Basic usage

Run ```setup.sh``` to set the variables in the ```~/.profile``` file of the user
you want to manage your minecraft servers.
Then you can run all scripts you want.

To automate backups or starting and stopping a server, use cronjobs.
To set up a cronjob run ```crontab -e``` and add a similar script as shown in
the example below.

# Available scripts

## Create server
To create a new server run the ```pst-create.sh``` script.

## List all available servers
To get an overview of all servers and their status, run the ```pst-list.sh```
script.

## Run
To run a server, use the following command:
```sh
$ ./pst-run <server_name>
```

The server must be created before and must stored in the path defined by the
```PAPER_HOME``` environment variable.

## Stop
To stop a server, use the following command:
```sh
$ ./pst-stop <server_name>
```

The script starts a background job, which stops the server after 1 hour.
To stop the server immediatly, use the ```/stop``` command of the minecraft
server.


# Supports backups

Backups are important! So, the toolchain has the ability to create backups from
your servers. To automate backups, use cronjobs.
To create a backup, run the following command:
```sh
$ ./pst-backup <server_name>
```

The script will create a ```<timestamp>.tar.gz``` file, which holds all data
of the selected server.

To restore a backup, use the
```sh
$ ./pst-restore <server_name>
```

command. This script lists all available backups for the selected server. You
can choose, which backup you want to restore. The backup will override the
current minecraft server directory.

# Example

Clone this repository with
```git clone https://github.com/dateiexplorer/paper-server-tools``` into your
home directory. Notice, that this example uses a user called "minecraft".

Run the ```setup.sh``` script an install all requirements.

Then create a new Server called ```mcserver``` with the ```pst-create.sh```
script in the ```scripts/``` directory.
Follow the instructions of the script. If the script is finished, your server
is ready to run.

Make sure, that you forward the port (default 25565) if you want to access your
server from the internet.

Then you can add cronjobs via ```crontab -e``` as shown below.

```
# Start minecraft server at 13h30 (every day)
# Notice, that the server starts 2 minutes before, because it needs some time
# before you're able to connect.
28 13 * * * /home/minecraft/paper-server-tools/scripts/pst-run.sh mcserver

# Stop minecraft server at 16h30 (every day)
# Notice that the stop jobs run for 1 hour before it shuts down the server.
30 15 * * * /home/minecraft/paper-server-tools/scripts/pst-stop.sh mcserver

# Backup minecraft server at 00:10 (every day)
10 00 * * * /home/minecraft/paper-server-tools/scripts/pst-backup.sh mcserver
```

Feel free to experiment with the commands and adjust it to your requirements.
