#! /bin/bash -l
# Run this script to create a new paper server instance.

current_pwd="$(pwd)"

# Check requirements for install and execution
echo "Checking requirements..."
requirements_present=true
for requirement in wget java screen; do
  printf "$requirement "
  if [ -x "$(command -v $requirement)" ]; then
    echo OK
  else
    echo MISSING
    "$requirements_present"=false
  fi
done | column -t 

if [ "$bool" = false ]; then
  echo "Please install missing requirements. Aborting..." 
  exit 
fi

printf "\n"

# Set server settings
read -p "Server name: " server_name

if [ -z $server_name ]; then
  echo "Server name must be set!"
  exit
fi


path="$PAPER_HOME/server/$server_name"
if [ -d "$path" ]; then
  echo "This directory already exists!"
  echo "Please remove the directory or enter another server name!"
  exit
fi

mkdir -p "$path"
cd "$path"

# Do things in $PAPER_HOME/$server_name/
read -p "Server version (e.g. 1.16.4): " version
wget -O paper_server.jar "https://papermc.io/api/v1/paper/$version/latest/download"

if [ $? -ne 0 ]; then
  echo "Download for this version failed. Aborting..."
  echo "Please check..."
  echo "  * your internet connection" 
  echo "  * write permissions for this directory" 
  echo "  * which version is available to download" 
  cd ..
  rm -r "$server_name"
  exit
fi

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

