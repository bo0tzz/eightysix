defmodule Eightysix.Bot do
  @bot :eightysix

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Print the bot's help")
  command("status", description: "Get the projector status")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(Eightysix.Middleware.Groupfilter)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :status, _msg}, context) do
    IO.puts("Handling status")
    reply = case Eightysix.Projector.status() |> IO.inspect() do
      :on -> "Projector is on"
      :off -> "Projector is off"
      :cooling -> "Projector is cooling"
      :warmup -> "Projector is warming up"
    end |> IO.inspect()
    answer(context, reply)
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end
end
