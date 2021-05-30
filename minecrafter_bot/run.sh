#!/bin/bash

# Get newest version of the repository
git pull

# Build bot
cargo build --release

# Run bot in background
exec ./target/release/minecrafter_bot &> bot.log &