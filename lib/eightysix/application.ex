defmodule Eightysix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @config_bindings [
    bot_token: ["bot", "token"],
    home_group: ["bot", "home_group"],
    projector_address: ["projector", "address"],
    projector_password: ["projector", "password"],
  ]

  use Application

  @impl true
  def start(_type, _args) do
    config_file = case System.fetch_env("EIGHTYSIX_CONFIG_FILE") do
      :error -> "config.toml"
      {:ok, value} -> value
    end

    providers = [
      %Vapor.Provider.File{path: config_file, bindings: @config_bindings}
    ]

    config = Vapor.load!(providers)

    Application.put_all_env([{Eightysix, Map.to_list(config)}])

    children = [
      ExGram,
      {Eightysix.Bot, [method: :polling, token: config.bot_token]},
      Eightysix.Scheduler,
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eightysix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
