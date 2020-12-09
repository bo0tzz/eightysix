defmodule Eightysix.Scheduler do
  use Quantum, otp_app: Eightysix

  def send_bins_reminder() do
    {_, week_num} = :calendar.iso_week_number()

    case rem(week_num, 2) do
      1 ->
        ExGram.send_message(
          Application.fetch_env!(Eightysix, :home_group),
          "Can someone please take the black bin out?",
          token: Application.fetch_env!(Eightysix, :bot_token)
        )
      _ -> nil
    end
  end
end
