import Config

config :eightysix, Eightysix.Scheduler,
  jobs: [
    {"0 15 * * 2", {Eightysix.Scheduler, :send_bins_reminder, []}}
  ]
