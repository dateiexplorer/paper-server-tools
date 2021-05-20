#!/bin/bash
# Run this script to setup your system for the paper-server-tools.
# It checks all requirements for the toolchain and setup some environment
# variables in the ~/.profile file.

# Show banner
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

# Add all required packages below
all_requirements_present=true
for requirement in tar gzip curl sed jq java screen; do
    if [ -x "$(command -v $requirement)" ]; then
        echo "  [*] $requirement"
    else
        echo "  [ ] $requirement"
        unset all_requirements_present
    fi
done

# Check if requirement is missing (requirement_is_missing is set)
if [ -z $all_requirements_present ]; then
    echo "Some requirements [ ] are missing."
    echo "Please install them and rerun the setup."
    exit
else
    echo "All requirements are installed. Let's go!"
fi

printf "\n"

# Set environment file
env_file="$HOME/.profile"

# Check if $env_file and environment variables already exists.
if [ -f "$env_file" &> /dev/null ] && [ $(cat "$env_file" \
        | grep -w "PAPER_HOME" | wc -l) -ne 0 ]; then
    echo "PAPER_HOME is already set:"
    echo "  $(cat "$env_file" | grep -w PAPER_HOME | cut -d = -f2)"
    echo "You can change the path by edit this environment variable in \
$env_file."
else
    echo "Set PAPER_HOME variable in $env_file:"
    echo "  PAPER_HOME=\"$HOME/Paper/server\""

    # Write to $env_file
    echo "export PAPER_HOME=\"$HOME/Paper/server\"" >> "$env_file"
fi

printf "\n"

# Check if PAPER_BACKUP environment variable is set.
if [ $(cat $env_file | grep -w "PAPER_BACKUP" | wc -l) -ne 0 ]; then
    echo "PAPER_BACKUP is already set:"
    echo "  $(cat "$env_file" | grep -w "PAPER_BACKUP" | cut -d = -f2)"
    echo "You can change the path by edit this environment variable in \
$env_file."
else
    echo "Set PAPER_BACKUP variable in $env_file:"
    echo "  PAPER_BACKUP=\"$HOME/Paper/backups\""

    # Write to $env_file
    echo "export PAPER_BACKUP=\"$HOME/Paper/backups\"" >> "$env_file"
fi

# Source the $env_file to apply changes and load environment variables in
# space.
printf "\n"
echo "Source $env_file to load environment variables..."
source "$env_file"

echo "Finished successfully!"
