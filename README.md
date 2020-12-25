# paper-server-tools
Collection of scripts to manage multiple Paper minecraft servers from command line.

# Usage

Run ```setup.sh``` to set the variables in the ```.bash_profile``` of the user you want to manage 
your minecraft servers.
Then run the scripts, you want.

To automate backups or starting and stopping a server, use cronjobs.
To set up a cronjobs run ```crontab -e``` and add the script as shown in the example below.


# Example

To use this example, create a new server called "slackbread" with the ```pst-create``` script.
Notice, that the example uses a separate user called "minecraft" for this jobs.
Then you can add cronjobs as shown below.

```
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command

# Start minecraft server at 13h30
28 13 * * * /home/minecraft/Scripts/pst-run.sh slackbread

# Stop minecraft server at 16h30
30 15 * * * /home/minecraft/Scripts/pst-stop.sh slackbread

# Start minecraft server at 19h00
58 18 * * * /home/minecraft/Scripts/pst-run.sh slackbread

# Stop minecraft server at 24h00
00 23 * * * /home/minecraft/Scripts/pst-stop.sh slackbread

# Backup minecraft server at 00:10
10 00 * * * /home/minecraft/Scripts/pst-backup.sh slackbread
```
