use std::env;

use std::process::Command;

use craftping::{Response, Result};

use serenity::prelude::*;
use serenity::async_trait;
use serenity::framework::{
    StandardFramework,
    standard::{
        Args, CommandResult,
        macros::{command, group}
    }
};
use serenity::model::prelude::*;

use tokio::time;

const PINGS_UNTIL_STOP: u8 = 3;

#[derive(Clone)]
struct ServerInfo {
    ip: String,
    port: u16
}

impl ServerInfo {
    fn new(ip: String, port: u16) -> ServerInfo {
        ServerInfo {
            ip,
            port
        }
    }
}

impl TypeMapKey for ServerInfo {
    type Value = ServerInfo;
}

struct Handler;

#[async_trait]
impl EventHandler for Handler {
    async fn ready(&self, _: Context, ready: Ready) {
        println!("{} is connected!", ready.user.name);
    }
}

#[group]
#[commands(craft)]
struct General;

async fn get_server_ping_response(server_info: &ServerInfo) -> Result<Response> {
    craftping::tokio::ping(&server_info.ip, server_info.port).await
}

fn start_watch_timer(server_info: &ServerInfo) {
    let interval = env::var("WATCH_TIMER_INTERVAL")
        .expect("Expected a watch timer interval in environment")
        .parse::<u64>().unwrap();

    let mut interval = time::interval(time::Duration::from_secs(interval));
    let mut stop_counter = 0;

    let server_info = server_info.clone();

    println!("Start watch timer with interval: {} sec", interval.period().as_secs());
    tokio::spawn(async move {
        loop {
            interval.tick().await;

            match get_server_ping_response(&server_info).await {
                // Server is UP
                Ok(response) => {
                    if response.online_players > 0 {
                        // If players on the server, reset the counter.
                        stop_counter = 0;
                        println!("Reset stop counter");
                    } else {
                        stop_counter += 1;
                        println!("No players on the server ({}/{})", stop_counter, PINGS_UNTIL_STOP);
                    }
                },
                // Server is DOWN or UNAVAILABLE
                Err(error) => {
                    stop_counter += 1;
                    println!("An error occured: {} ({}/{})", error, stop_counter, PINGS_UNTIL_STOP);
                }
            };

            if stop_counter >= PINGS_UNTIL_STOP {
                // Stop the server
                println!("Stop current server");
                do_server_action(&["stop", "current", "now"]);

                // Stop this timer
                break;
            }
        }
    });
}

fn do_server_action(action: &[&str]) -> bool {
    // Start subprocess to start the server
    match Command::new("../scripts/pst-cli.sh").args(action).spawn() {
        Ok(mut child) => {
            match child.wait() {
                Ok(exit_code) => {
                    exit_code.success()
                },
                Err(_) => false
            }
        },
        Err(_) => false
    }
}

#[command]
async fn craft(ctx: &Context, msg: &Message, _: Args) -> CommandResult {
    let data_read = ctx.data.read().await;
    let server_info = data_read.get::<ServerInfo>().expect("Expected server info");

    msg.channel_id.delete_message(&ctx.http, msg.id).await.unwrap();

    match get_server_ping_response(server_info).await {
        // Server is already UP
        Ok(response) => {
            msg.channel_id.say(&ctx.http,
                format!("Hey **{}**, server is already up! Reachable under:\n```{}:{}```\nCurrently **{}/{}** players are online.",
                    msg.author.name, server_info.ip, server_info.port, response.online_players, response.max_players)).await?;
        },
        // Server is DOWN
        Err(_) => {
            let message = match do_server_action(&["run", "current"]) {
                true => {
                    // Start the watch timer
                    start_watch_timer(&server_info);
                    format!("Yeah, start the server. Will available under:\n```{}:{}```", 
                        server_info.ip, server_info.port)},
                false => "Currently it's not possible to start the server!".to_string()
            };

            msg.channel_id.say(&ctx.http, message).await?;
        }
    }

    Ok(())
}

#[tokio::main]
async fn main() {
    // Load environment variables from ./.env
    dotenv::dotenv().expect("Failed to load .env file");

    let token = env::var("DISCORD_TOKEN")
        .expect("Expected a token in the environment");
    
    let server_ip = env::var("SERVER_IP")
        .expect("Expected a server ip in the environment");

    let server_port = env::var("SERVER_PORT")
        .expect("Expected a server port in the environment")
        .parse::<u16>()
        .unwrap();
    
    let server_info = ServerInfo::new(server_ip, server_port);

    // Create framework
    let framework = StandardFramework::new()
        .configure(|c| c.prefix("!"))
        .group(&GENERAL_GROUP); // Because of the `General` group
    
    let mut client = Client::builder(&token)
        .framework(framework)
        .event_handler(Handler)
        .await
        .expect("Error creating client");
    
    // Start a watch timer so that the discord bot already track server status
    start_watch_timer(&server_info);

    {
        let mut data = client.data.write().await;
        data.insert::<ServerInfo>(server_info);
    }

    // Start client
    if let Err(why) = client.start().await {
        eprintln!("{:?}", why);
    }
}