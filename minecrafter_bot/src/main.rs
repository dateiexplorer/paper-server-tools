// Standardlibrary
use std::env;
use std::process::{Command, ExitStatus};

// Craftping
use craftping::{Response, Result};

// Serenity
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

// Tokio
use tokio::time;

// Chrono
use chrono::prelude::*;

fn log(msg: &str) {
    println!("[{}] {}", Utc::now().format("%Y-%m-%d %H:%M:%S"), msg);
}

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
        log(format!("{} is connected", ready.user.name).as_str());
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

    log(format!("Start watch timer with interval: {} sec", interval.period().as_secs()).as_str());
    tokio::spawn(async move {
        loop {
            interval.tick().await;

            match get_server_ping_response(&server_info).await {
                // Server is UP
                Ok(response) => {
                    if response.online_players > 0 {
                        // If players on the server, reset the counter.
                        stop_counter = 0;
                        log("Players are on the server, reset stop counter");
                    } else {
                        stop_counter += 1;
                        log(format!("No players on the server ({}/{})", stop_counter, PINGS_UNTIL_STOP).as_str());
                    }
                },
                // Server is DOWN or UNAVAILABLE
                Err(error) => {
                    stop_counter += 1;
                    log(format!("An error occured: {} ({}/{})", error, stop_counter, PINGS_UNTIL_STOP).as_str());
                }
            };

            if stop_counter >= PINGS_UNTIL_STOP {
                // Stop the server
                log("Stop server");
                do_server_action(&["stop", "current", "now"]);

                // Stop this timer
                break;
            }
        }
    });
}

fn do_server_action(action: &[&str]) -> Option<ExitStatus> {
    if let Some(mut child) = Command::new("../scripts/pst-cli.sh").args(action).spawn().ok() {
        return child.wait().ok()
    }

    None
}

#[command]
async fn craft(ctx: &Context, msg: &Message, _: Args) -> CommandResult {
    let data_read = ctx.data.read().await;
    let server_info = data_read.get::<ServerInfo>().expect("Expected server info");

    // Uncomment to delete the message
    // msg.channel_id.delete_message(&ctx.http, msg.id).await.unwrap();
    
    log(format!("{} asks to start the server", msg.author.name).as_str());

    match get_server_ping_response(server_info).await {
        // Server is already UP
        Ok(response) => {
            log("Server is already running");
            msg.channel_id.say(&ctx.http,
                format!("Hey, server is already up! Reachable under:\n```{}:{}```\nCurrently **{}/{}** players are online.",
                    server_info.ip, server_info.port, response.online_players, response.max_players)).await?;
        },
        // Server is DOWN
        Err(_) => {
            let message = match do_server_action(&["run", "current"]) {
                Some(_) => {
                    log("Start server");

                    // Start the watch timer
                    start_watch_timer(&server_info);
                    format!("Yeah, start the server. Will available under:\n```{}:{}```", 
                        server_info.ip, server_info.port)},
                None => {
                    log("Not possible to start the server");
                    "Currently it's not possible to start the server!".to_string()
                }
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