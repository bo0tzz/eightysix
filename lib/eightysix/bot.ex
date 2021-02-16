defmodule Eightysix.Bot do
  @bot :eightysix

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  regex(~r/l(u|o)+nch|di+nner/i, :coffee_time)

  command("add", description: "Add an item to the shopping list")
  command("coffee", description: "Turn the coffee machine on or off")

  command("get", description: "Get the current shopping list")
  command("clear", description: "Clear the shopping list")

  command("remove", description: "Remove an item from the shopping list")

  command("status", description: "Get the projector status")
  command("on", description: "Turn the projector on")
  command("off", description: "Turn the projector off")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(Eightysix.Middleware.Groupfilter)

  def bot(), do: @bot

  def handle({:command, :on, _msg}, context), do: answer(context, Eightysix.Projector.on())
  def handle({:command, :off, _msg}, context), do: answer(context, Eightysix.Projector.off())

  def handle({:command, :status, _msg}, context),
    do: answer(context, Eightysix.Projector.status())

  def handle({:command, :add, msg}, context), do: answer(context, Eightysix.ShoppingList.add(msg))

  def handle({:command, :remove, msg}, context),
    do: answer(context, Eightysix.ShoppingList.remove(msg))

  def handle({:command, :get, _msg}, context), do: answer(context, Eightysix.ShoppingList.get())

  def handle({:command, :clear, _msg}, context),
    do: answer(context, Eightysix.ShoppingList.clear())

  def handle({:command, :coffee, _msg}, context) do
    msg = case Eightysix.Coffee.toggle() do
      :true -> "Turned coffee on"
      :false -> "Turned coffee off"
    end
    answer(context, msg)
  end

  def handle({:regex, :coffee_time, _msg}, context) do
    case Eightysix.Coffee.on?() do
      :false -> :true = Eightysix.Coffee.on()
                answer(context, "Turned coffee on :)")

      _ -> :ok
    end
  end
end
