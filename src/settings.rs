use config::Config;
use serde_derive::Deserialize;

fn read_config() -> Config {
    let mut settings = config::Config::default();
    settings
        .merge(config::File::with_name("settings"))
        .expect("Failed to read settings file");
    settings
}

#[derive(Deserialize)]
pub struct Settings {
    pub projector: ProjectorSettings,
    pub bins: BinSettings,
    pub telegram: TelegramSettings,
}

#[derive(Deserialize)]
pub struct TelegramSettings {
    pub token: String,
    pub home_chat: i64,
    pub bot_name: String,
}

#[derive(Deserialize)]
pub struct ProjectorSettings {
    pub address: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct BinSettings {
    pub day: u8,
    pub even_week_message: String,
    pub odd_week_message: String,
}

pub fn settings() -> Settings {
    let settings = read_config();
    settings.try_into().expect("Could not read config!")
}
