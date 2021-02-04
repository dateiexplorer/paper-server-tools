#! /bin/bash
# Run this script to setup your system for the paper-server-tools.

if [ $(cat "$HOME/.bash_profile" | grep "PAPER_HOME" | wc -l) -ne 0 ]; then
    echo "PAPER_HOME is already set: $(cat $HOME/.bash_profile | grep PAPER_HOME | cut -d = -f2)"
    echo "You can change the path by edit this variable in the ~/.bash_profile file."
else
    echo "Set PAPER_HOME variable in ~/.bash_profile" 
    echo "PAPER_HOME=\"$HOME/Paper\"" >> "$HOME/.bash_profile"
fi

if [ $(cat "$HOME/.bash_profile" | grep "PAPER_BACKUP" | wc -l) -ne 0 ]; then
    echo "PAPER_BACKUP is already set: $(cat $HOME/.bash_profile | grep PAPER_BACKUP | cut -d = -f2)"
    echo "You can change the path by edit this variable in the ~/.bash_profile file."
else
    echo "Set PAPER_BACKUP variable in ~/.bash_profile" 
    echo "PAPER_BACKUP=\"$HOME/Paper/backups\"" >> "$HOME/.bash_profile"
fi



