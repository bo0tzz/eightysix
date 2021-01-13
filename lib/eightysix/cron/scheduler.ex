defmodule Eightysix.Scheduler do
  use Quantum, otp_app: :eightysix
  require Logger

  def send_bins_reminder() do
    {_, week_num} = :calendar.iso_week_number()
    Logger.info("Running bins reminder handler on week #{week_num}")

    case rem(week_num, 2) do
      0 ->
        Logger.info("Sending reminder")
        ExGram.send_message(
          Application.fetch_env!(Eightysix, :home_group),
          "Can someone please take the black bin out?",
          token: Application.fetch_env!(Eightysix, :bot_token)
        ) |> case do
          {:ok, _} -> Logger.info("Successfully sent reminder")
          {:error, e} -> Logger.error("Failed to send reminder: #{inspect(e)}")
        end

      _ ->
        nil
    end
  end
end
