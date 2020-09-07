mod bin_day;
mod projector;
mod settings;

use crate::bin_day::{run_on_timer, BinDay};
use crate::projector::Projector;
use pjlink::PowerStatus;

fn main() {
    let config = settings::settings();
    let projector = Projector::new(&config).expect("Could not connect to projector");
    let binday = BinDay::new(&config, |s| println!(s));
    run_on_timer(binday.check_bins);
}
