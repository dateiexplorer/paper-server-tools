use std::env;

use std::process::Command;
use std::process::Child;

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
#[commands(ping, craft)]
struct General;

async fn get_server_ping_response(server_info: &ServerInfo) -> Result<Response> {
    craftping::tokio::ping(&server_info.ip, server_info.port).await
}

async fn start_server() -> std::io::Result<Child> {
    // Start subprocess to start the server
    Command::new("../scripts/pst-cli.sh")
        .args( &["run", "current"])
        .spawn()
}

#[command]
async fn ping(ctx: &Context, msg: &Message, _: Args) -> CommandResult {
    let data_read = ctx.data.read().await;
    let server_info = data_read.get::<ServerInfo>().expect("Expected server info");

    let result = get_server_ping_response(server_info).await;
    println!("{:#?}", result);

    let response = match result {
        Ok(result) => result.description.text,
        Err(_) => "Server is down :(".to_string()
    };

    msg.channel_id.say(&ctx.http, response).await?;
    Ok(())
}

#[command]
async fn craft(ctx: &Context, msg: &Message, _: Args) -> CommandResult {
    let data_read = ctx.data.read().await;
    let server_info = data_read.get::<ServerInfo>().expect("Expected server info");

    match get_server_ping_response(server_info).await {
        // Server is already UP
        Ok(response) => {
            msg.channel_id.say(&ctx.http,
                format!("Hey, server is already up!\nCurrently **{}/{}** players are online.",
                    response.online_players, response.max_players)).await?;
        },
        // Server is DOWN
        Err(_) => {
            let message = match start_server().await {
                Ok(_) => format!("Yeah, start the server. Will available under:\n```{}:{}```", 
                            server_info.ip, server_info.port),
                Err(_) => "An error occured! Please inform the server admin to solve this issue.".to_string()
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
    
    // Create framework
    let framework = StandardFramework::new()
        .configure(|c| c.prefix("!"))
        .group(&GENERAL_GROUP); // Because of the `General` group
    
    let mut client = Client::builder(&token)
        .framework(framework)
        .event_handler(Handler)
        .await
        .expect("Error creating client");

    {
        let mut data = client.data.write().await;
        data.insert::<ServerInfo>(ServerInfo::new(server_ip, server_port));
    }

    // Start client
    if let Err(why) = client.start().await {
        eprintln!("{:?}", why);
    }
}
