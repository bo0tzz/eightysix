use crate::settings::Settings;
use chrono::{Datelike, Duration};
use time::Duration;
use timer::{Guard, Timer};

static MESSAGE_FORMAT: &str = "The {} should be put out!";

pub struct BinDay {
    weekday: chrono::Weekday,
    even_week_message: String,
    odd_week_message: String,
    callback: fn(String),
}

impl BinDay {
    pub fn new(settings: &Settings, callback: fn(String)) -> BinDay {
        let weekday = chrono::Weekday::from_u8(settings.bin_day).expect("Invalid weekday format!");
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

        let message = format!(MESSAGE_FORMAT, message);
        self.callback(message);
    }
}

pub fn run_on_timer(fun: fn()) -> Guard {
    // The function won't be called until 6 hours from scheduling it, so let's call it now as well
    fun();

    let timer = Timer::new();
    timer.schedule_repeating(Duration::hours(6), fun)
}
