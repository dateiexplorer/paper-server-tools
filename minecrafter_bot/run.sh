#!/bin/bash

# Get newest repository
git pull

# Start bot
cargo build --release
exec ./target/release/minecrafter_bot &> bot.log