defmodule Eightysix.MixProject do
  use Mix.Project

  def project do
    [
      app: :eightysix,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Eightysix.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:vapor, "~> 0.10"},
      {:ex_gram, "~> 0.15"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"}
    ]
  end
end