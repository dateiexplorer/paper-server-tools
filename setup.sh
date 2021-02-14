#!/bin/bash
# Run this script to setup your system for the paper-server-tools.

echo -e "
Welcome to the  __                 __
______  _______/  |_  ____   ____ |  |   ______
\____ \/  ___/\   __\/  _ \ /  _ \|  |  /  ___/
|  |_> >___ \  |  | (  <_> |  <_> )  |__\___ \\
|   __/____  > |__|  \____/ \____/|____/____  >
|__|       \/                               \/

"

# Check requirements for execution
echo "Checking requirements..."

for requirement in tar gzip curl sed jq java screen; do
    if ! [ -x "$(command -v $requirement)" ]; then
        echo -e "\
The following programm is required, but missing:
    $requirement
Please install it and restart the setup.
"
        exit -1
    fi
done

echo "All requirements are installed. Let's go!"
printf "\n"


if [ -f "$HOME/.bash_profile" &> /dev/null ] && [ $(cat "$HOME/.bash_profile" \
        | grep -w "PAPER_HOME" | wc -l) -ne 0 ]; then
    echo "PAPER_HOME is already set:"
    echo "    $(cat $HOME/.bash_profile | grep -w PAPER_HOME | cut -d = -f2)"
    echo "You can change the path by edit this variable in the ~/.bash_profile \
file."
else
    echo "Set PAPER_HOME variable in ~/.bash_profile"
    echo "PAPER_HOME=\"$HOME/Paper\"" >> "$HOME/.bash_profile"
fi

printf "\n"
if [ $(cat "$HOME/.bash_profile" | grep -w "PAPER_BACKUP" | wc -l) -ne 0 ]; then
    echo "PAPER_BACKUP is already set:"
    echo "    $(cat $HOME/.bash_profile | grep -w "PAPER_BACKUP" | cut -d = -f2)"
    echo "You can change the path by edit this variable in the ~/.bash_profile \
file."
else
    echo "Set PAPER_BACKUP variable in ~/.bash_profile"
    echo "PAPER_BACKUP=\"$HOME/Paper/backups\"" >> "$HOME/.bash_profile"
fi