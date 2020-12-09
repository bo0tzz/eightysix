mod bin_day;
mod projector;
mod settings;

use crate::bin_day::{BinDay};
use crate::projector::Projector;
use futures::StreamExt;
use pjlink::PowerStatus;
use regex::Regex;
use telegram_bot::*;

#[tokio::main]
async fn main() -> Result<(), Error> {
    let config = settings::settings();
    let projector = Projector::new(&config.projector).expect("Could not connect to projector.");

    let api = Api::new(config.telegram.token);
    let home_chat = telegram_bot::types::refs::ChatId::from(config.telegram.home_chat);

    let binday = BinDay::new(&config.bins, |s: String| {
        let chat = telegram_bot::types::refs::ChatId::from(config.telegram.home_chat);
        let message = SendMessage::new(chat.to_chat_ref(), s);
        api.send(message);
    });

    let command_regex = Regex::new(r"/(\w+)(@\w+)?").unwrap();

    let mut stream = api.stream();
    while let Some(update) = stream.next().await {
        // If the received update contains a new message...
        let update = update?;
        if let UpdateKind::Message(message) = update.kind {
            if message.chat.id() != home_chat {
                println!(
                    "Ignoring message from {} in {}",
                    message.from.first_name,
                    message.chat.id()
                );
                if let Some(user) = &message.from.username {
                    println!("username: {}", user);
                };
                if let Some(text) = message.text() {
                    println!("content of ignored message: {}", text);
                }
                continue;
            }
            if let MessageKind::Text { ref data, .. } = message.kind {
                if let Some(capture) = command_regex.captures(data) {
                    if let Some(group) = capture.get(1) {
                        let command = group.as_str();
                        println!("Processing command /{}", command);
                        let reply = match command {
                            "on" => match projector.status() {
                                Ok(status) => match status {
                                    PowerStatus::Off => match projector.on() {
                                        Ok(_) => "Turned projector on.",
                                        Err(_) => "Could not turn on the projector.",
                                    },
                                    PowerStatus::Cooling => {
                                        "Projector is still cooling, try again later"
                                    }
                                    _ => "Projector is already on.",
                                },
                                Err(_) => "Failed to connect to projector.",
                            },
                            "off" => match projector.status() {
                                Ok(status) => match status {
                                    PowerStatus::On => match projector.off() {
                                        Ok(_) => "Turned projector off.",
                                        Err(_) => "Could not turn off the projector.",
                                    },
                                    PowerStatus::Warmup => {
                                        "Projector is still warming up, try again later"
                                    }
                                    _ => "Projector is already off.",
                                },
                                Err(_) => "Failed to connect to projector.",
                            },
                            "status" => match projector.status() {
                                Ok(status) => match status {
                                    PowerStatus::Off => "Projector is off.",
                                    PowerStatus::On => "Projector is on.",
                                    PowerStatus::Cooling => "Projector is cooling.",
                                    PowerStatus::Warmup => "Projector is warming up.",
                                },
                                Err(_) => "Failed to connect to projector.",
                            },

                            _ => "",
                        };

                        if reply.len() != 0 {
                            api.send(message.text_reply(reply)).await?;
                        }
                    }
                }
            }
        }
    }
    Ok(())
}
