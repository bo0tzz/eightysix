defmodule Eightysix.Coffee do
  use HTTPoison.Base

  @expected_fields ~w(
    ison has_timer timer_started timer_duration timer_remaining source
  )

  @coffee_times [
    {~T(11:00:00), ~T(14:00:00)},
    {~T(17:00:00), ~T(20:00:00)}
  ]

  def process_request_url(url) do
    Application.fetch_env!(Eightysix, :coffee_address) <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def toggle(), do: turn("toggle")
  def on(), do: turn("on")
  def on?(), do: get_path("/relay/0")

  def turn(state) do
    get_path("/relay/0?turn=" <> state)
  end

  def get_path(path) do
    Eightysix.Coffee.get!(path).body[:ison]
  end

  def coffee_time() do
    case {Enum.any?(@coffee_times, &currently_between/1), Eightysix.Coffee.on?()} do
      {true, false} ->
        :true = Eightysix.Coffee.on()
        {:ok, "Turned coffee on :)"}

      _ -> :ok
    end
  end

  def currently_between({start, endt}) do
    today = Timex.to_datetime(Timex.today())
    now = Timex.local()
    s = Timex.add(today, Timex.Duration.from_time(start))
    e = Timex.add(today, Timex.Duration.from_time(endt))
    Timex.between?(now, s, e)
  end
end
