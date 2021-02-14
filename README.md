# paper-server-tools

Collection of scripts to manage multiple Paper minecraft servers from command 
line.

# What doesn't work yet

* Restore backups automatically and list them
* Stop a minecraft server immediatly with a script (use the ```/stop```-command)
  in your minecraft server session to terminate the server

# Basic usage

Run ```setup.sh``` to set the variables in the ```.bash_profile``` of the user
you want to manage your minecraft servers.
Then run the scripts, you want.

To automate backups or starting and stopping a server, use cronjobs.
To set up a cronjobs run ```crontab -e``` and add the script as shown in the 
example below.

To get an overview of all servers and their status, run the ```pst-list.sh```
script.

# Supports backups

Backups are important! So, the toolchain has the ability to create backups from
your servers. To automate backups, use cronjobs.

# Example

To use this example, create a new server called "mcserver" with the 
```pst-create.sh``` script.

Notice, that the example uses a separate user called "minecraft" for this jobs.
Then you can add cronjobs as shown below.

```
# Start minecraft server at 13h30 (every day)
# Notice, that the server starts 2 minutes before, because it needs some time
# before you're able to connect.
28 13 * * * /home/minecraft/pst/scripts/pst-run.sh mcserver

# Stop minecraft server at 16h30 (every day)
30 15 * * * /home/minecraft/pst/scripts/pst-stop.sh mcserver

# Backup minecraft server at 00:10 (every day)
10 00 * * * /home/minecraft/pst/scripts/pst-backup.sh mcserver
```
