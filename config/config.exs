import Config

config Eightysix, Eightysix.Scheduler,
  jobs: [
    {"0 15 * * 3", {Eightysix.Scheduler, :send_bins_reminder, []}}
  ]
