defmodule Eightysix.Projector do
  alias Eightysix.PjLink

  def status() do
    addr = Application.fetch_env!(Eightysix, :projector_address) |> to_charlist()
    pass = Application.fetch_env!(Eightysix, :projector_password)
    PjLink.connect(addr, pass)
    |> PjLink.status?()
  end
end
