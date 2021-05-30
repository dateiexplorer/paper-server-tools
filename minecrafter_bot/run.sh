#!/bin/bash

# Print banner
echo -e "
                __                 __
______  _______/  |_  ____   ____ |  |   ______
\____ \/  ___/\   __\/  _ \ /  _ \|  |  /  ___/
|  |_> >___ \  |  | (  <_> |  <_> )  |__\___ \\
|   __/____  > |__|  \____/ \____/|____/____  >
|__|       \/                               \/

Setting up the newest version of the Minecrafter bot
"

# Get newest version of the repository
echo "Get newest version..."
git pull

# Build bot
echo "Build bot..."
cargo build --release

# Stop all other running instances
echo "Kill running instances of the bot..."
for process in $(ps -ef | grep "minecrafter_bot" | \
    grep -v "grep" | awk '{ print $2 }'); do
    
    kill "$process"
done

# Run bot in background
echo "Running bot..."
exec ./target/release/minecrafter_bot &> bot.log &