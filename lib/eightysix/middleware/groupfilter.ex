defmodule Eightysix.Middleware.Groupfilter do
  use ExGram.Middleware

  alias ExGram.Cnt

  def call(%Cnt{update: %{message: %{chat: %{id: id}}}} = cnt, _) do
    case id == Application.fetch_env!(Eightysix, :home_group) do
      true ->
        cnt

      false ->
        IO.puts("Ignoring message from unknown group #{id}")
        %{cnt | halted: true}
    end
  end
end
