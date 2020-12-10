defmodule Eightysix.Bot do
  @bot :eightysix

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("status", description: "Get the projector status")
  command("on", description: "Turn the projector on")
  command("off", description: "Turn the projector off")

  command("add", description: "Add an item to the shopping list")
  command("get", description: "Get the current shopping list")
  command("clear", description: "Clear the shopping list")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(Eightysix.Middleware.Groupfilter)

  def bot(), do: @bot

  def handle({:command, :on, _msg}, context), do: answer(context, Eightysix.Projector.on())
  def handle({:command, :off, _msg}, context), do: answer(context, Eightysix.Projector.off())

  def handle({:command, :status, _msg}, context),
    do: answer(context, Eightysix.Projector.status())

  def handle({:command, :add, msg}, context), do: answer(context, Eightysix.ShoppingList.add(msg))
  def handle({:command, :get, _msg}, context), do: answer(context, Eightysix.ShoppingList.get())

  def handle({:command, :clear, _msg}, context),
    do: answer(context, Eightysix.ShoppingList.clear())
end
