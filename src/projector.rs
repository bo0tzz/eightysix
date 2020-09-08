use crate::settings::ProjectorSettings;
use pjlink::PowerStatus::{Off, On};
use pjlink::{PjlinkDevice, PowerStatus};

pub struct Projector {
    link: PjlinkDevice,
}

#[derive(Debug)]
pub struct ProjectorError {}

impl Projector {
    pub fn new(settings: &ProjectorSettings) -> Result<Projector, ProjectorError> {
        match PjlinkDevice::new_with_password(&settings.address, &settings.password) {
            Ok(link) => Ok(Projector { link }),
            Err(_) => Err(ProjectorError {}),
        }
    }

    pub fn status(&self) -> Result<PowerStatus, ProjectorError> {
        match self.link.get_power_status() {
            Ok(status) => Ok(status),
            Err(_) => Err(ProjectorError {}),
        }
    }

    pub fn off(&self) -> Result<PowerStatus, ProjectorError> {
        self.status().and_then(|status| match status {
            Off => Ok(Off),
            On => match self.link.power_off() {
                Ok(_) => Ok(On),
                Err(_) => Err(ProjectorError {}),
            },
            _ => Err(ProjectorError {}),
        })
    }

    pub fn on(&self) -> Result<PowerStatus, ProjectorError> {
        self.status().and_then(|status| match status {
            On => Ok(On),
            Off => match self.link.power_on() {
                Ok(_) => Ok(Off),
                Err(_) => Err(ProjectorError {}),
            },
            _ => Err(ProjectorError {}),
        })
    }
}
