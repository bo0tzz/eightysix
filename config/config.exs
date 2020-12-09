import Config

config :eightysix, Eightysix.Scheduler,
  jobs: [
    {"0 15 * * 3", {Eightysix.Scheduler, :send_bins_reminder, []}}
  ]
