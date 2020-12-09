defmodule Eightysix.Projector do
  alias Eightysix.PjLink

  def status() do
    connect()
    |> PjLink.status?()
    |> case do
      :on -> "Projector is on"
      :off -> "Projector is off"
      :cooling -> "Projector is cooling down"
      :warmup -> "Projector is warming up"
    end
  end

  def on() do
    projector = connect()
    case PjLink.status?(projector) do
      :on -> "Projector is already on"
      :warmup -> "Projector is warming up"
      _ -> case PjLink.on(projector) do
        {:ok, :on} -> "Turned projector on"
        {:fail, status} -> "Failed to turn projector on, current status is #{status}"
      end
    end
  end

  def off() do
    projector = connect()
    case PjLink.status?(projector) do
      :off -> "Projector is already off"
      :cooling -> "Projector is cooling down"
      _ -> case PjLink.off(projector) do
        {:ok, :off} -> "Turned projector off"
        {:fail, status} -> "Failed to turn projector off, current status is #{status}"
      end
    end
  end

  defp connect() do
    addr = Application.fetch_env!(Eightysix, :projector_address) |> to_charlist()
    pass = Application.fetch_env!(Eightysix, :projector_password)
    PjLink.connect(addr, pass)
  end
end
