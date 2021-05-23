# paper-server-tools

Collection of scripts to manage multiple Paper minecraft servers from command 
line.

# Basic usage

Run ```./pst-cli.sh setup``` to set the variables in the ```~/.profile``` file
of the user you want to manage your minecraft servers.
Then you can run all the other commands.

To automate backups or starting and stopping a server, use cronjobs.
To set up a cronjob run ```crontab -e``` and add a similar script as shown in
the example below.

# Available commands

The following snippet shows an overview of all available commands that work
so far:

```
                __                 __
______  _______/  |_  ____   ____ |  |   ______
\____ \/  ___/\   __\/  _ \ /  _ \|  |  /  ___/
|  |_> >___ \  |  | (  <_> |  <_> )  |__\___ \
|   __/____  > |__|  \____/ \____/|____/____  >
|__|       \/                               \/

Version 1.0.0

Justus Röderer <justus.roederer@outlook.com>"

Usage:
  setup                 Setup environment variables
  create                Create a new server
  list                  List all available servers
  run <server>          Run a server
  stop <server> [now]   Stop a server
  restart <server>      Restart a server
  backup <server>       Create a backup from the server
  restore <server>      Restore a server from a backup
  current <server>      Set the given server as 'current'
  help                  Print this help dialog
```

To stop a server, the toolchain provides an additional daemon script
```stopd.sh```, which must be stored in the same directory as the
```pst-cli.sh``` script to work.

# Supports backups

Backups are important! So, the toolchain has the ability to create backups from
your servers. To automate backups, use cronjobs.
To create a backup, run the following command:
```sh
./pst-cli.sh backup <server>
```

The script will create a ```<timestamp>.tar.gz``` file, which holds all data
of the selected server.

To restore a backup, use the
```sh
./pst-cli.sh restore <server>
```

command. This command lists all available backups for the selected server. You
can choose, which backup you want to restore. The backup will override the
current minecraft server directory.

# Example

Clone this repository with
```git clone https://github.com/dateiexplorer/paper-server-tools``` into your
home directory. Notice, that this example uses a user called "minecraft".

Run the ```setup``` command and install all requirements.

Then create a new Server called ```mcserver``` with the
```./pst-cli.sh create mcserver``` command. The CLI Script is stored in the
```scripts/``` directory. Follow the instructions of the script. If the script
is finished, your server is ready to run.

Make sure, that you forward the port (default 25565) if you want to access your
server from the internet.

Then you can add cronjobs via ```crontab -e``` as shown below.

```
# Start minecraft server at 13h30 (every day)
# Notice, that the server starts 2 minutes before, because it needs some time
# before you're able to connect.
28 13 * * * /home/minecraft/paper-server-tools/scripts/pst-cli.sh start mcserver

# Stop minecraft server at 16h30 (every day)
# Notice that the stop jobs run for 1 hour before it shuts down the server.
30 15 * * * /home/minecraft/paper-server-tools/scripts/pst-cli.sh stop mcserver

# Backup minecraft server at 00:10 (every day)
10 00 * * * /home/minecraft/paper-server-tools/scripts/pst-cli.sh backup mcserver
```

Feel free to experiment with the commands and adjust it to your requirements.
