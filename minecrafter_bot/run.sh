#!/bin/bash

# Stop all other running instances
for process in $(ps -ef | grep "minecrafter_bot" | \
    grep -v "grep" | awk '{ print $2 }'); do
    
    kill "$process"
done

# Get newest version of the repository
git pull

# Build bot
cargo build --release

# Run bot in background
exec ./target/release/minecrafter_bot &> bot.log &