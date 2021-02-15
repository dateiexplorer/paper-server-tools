#! /bin/bash -l
# Run this script to create a new paper server instance.

if [ -z "$PAPER_HOME" ] || [ -z "$PAPER_BACKUP" ]; then
    echo "Please run the setup.sh script before using this script."
fi

set -e

echo -e "
                __                 __
______  _______/  |_  ____   ____ |  |   ______
\____ \/  ___/\   __\/  _ \ /  _ \|  |  /  ___/
|  |_> >___ \  |  | (  <_> |  <_> )  |__\___ \\
|   __/____  > |__|  \____/ \____/|____/____  >
|__|       \/                               \/

Create new server...
"

current_pwd="$(pwd)"

# Set server settings
read -p "Server name: " server_name

if [ -z $server_name ]; then
  echo "Server name must be set!"
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
    "https://papermc.io/api/v1/paper/$version/latest/download" &> /dev/null


echo "Execute server jar for the first time..."
java -jar -Xms1024M -Xmx1024M paper_server.jar

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
echo "Server setup was successfull."
echo "Default port is 25565."

cd "$current_pwd"

