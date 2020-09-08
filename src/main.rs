// mod bin_day;
mod projector;
mod settings;
//
// use crate::bin_day::{run_on_timer, BinDay};
use crate::projector::Projector;
// use pjlink::PowerStatus;
use futures::StreamExt;
use pjlink::PowerStatus;
use regex::Regex;
use telegram_bot::*;

#[tokio::main]
async fn main() -> Result<(), Error> {
    let config = settings::settings();
    let projector = Projector::new(&config.projector).expect("Could not connect to projector");
    //
    let api = Api::new(config.telegram.token);
    //
    // let binday = BinDay::new(&config.bins, &|s: String| {
    //     let chat = telegram_bot::types::refs::ChatId::from(config.telegram.home_chat);
    //     let message = SendMessage::new(chat.to_chat_ref(), s);
    //     api.send(message);
    // });
    // run_on_timer(move || binday.check_bins());

    let command_regex = Regex::new(r"\/(\w+)(@\w+)?").unwrap();

    let mut stream = api.stream();
    while let Some(update) = stream.next().await {
        // If the received update contains a new message...
        let update = update?;
        if let UpdateKind::Message(message) = update.kind {
            if let MessageKind::Text { ref data, .. } = message.kind {
                if let Some(capture) = command_regex.captures(data) {
                    if let Some(group) = capture.get(0) {
                        let reply = match group.as_str() {
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

                            _ => "",
                        };
                        api.send(message.text_reply(reply)).await?;
                    }
                }
            }
        }
    }
    Ok(())
}
