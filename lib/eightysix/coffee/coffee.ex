defmodule Eightysix.Coffee do
  use HTTPoison.Base

  @expected_fields ~w(
    ison has_timer timer_started timer_duration timer_remaining source
  )

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

  def turn(state) do
    Eightysix.Coffee.get!("/relay/0?turn=" <> state).body[:ison]
  end
end
