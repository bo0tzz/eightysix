use crate::settings::BinSettings;
use chrono::Datelike;
use timer::{Guard, Timer};
use num_traits::cast::FromPrimitive;

pub struct BinDay {
    weekday: chrono::Weekday,
    even_week_message: String,
    odd_week_message: String,
    callback: fn(String),
}

impl BinDay {
    pub fn new(settings: &BinSettings, callback: fn(String)) -> BinDay {
        let weekday = chrono::Weekday::from_u64(settings.day).expect("Invalid weekday format!");
        BinDay {
            weekday,
            even_week_message: String::from(&settings.even_week_message),
            odd_week_message: String::from(&settings.odd_week_message),
            callback,
        }
    }

    pub fn check_bins(&self) {
        let date = chrono::Local::today();
        let message = match date.iso_week().week() % 2 {
            0 => &self.even_week_message,
            _ => &self.odd_week_message,
        };

        (self.callback)(message.to_string());
    }
}
