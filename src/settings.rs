use config::Config;
use serde_derive::Deserialize;

fn read_config() -> Config {
    let mut settings = config::Config::default();
    settings.merge(config::File::with_name("settings")).unwrap();
    settings
}

#[derive(Deserialize)]
pub struct Settings {
    pub projector_address: String,
    pub projector_password: String,
    pub bin_day: u8,
    pub even_week_message: String,
    pub odd_week_message: String,
}

pub fn settings() -> Settings {
    let settings = read_config();
    settings.try_into().expect("Could not read config!")
}
