defmodule Eightysix.ShoppingList do
  alias Eightysix.ShoppingList.Storage

  def add(%{text: msg}) do
    case sanitize(msg) do
      "" ->
        """
        Please specify something to add, for example: /add rice.
        You can also add multiple things by separating them with a new line, for example:
        /add rice
        beans
        milk
        """

      items ->
        String.split(items, "\n") |> add()
    end
  end

  def add([item]) do
    :ok = Storage.add(item)
    "#{item} was added to the shopping list."
  end

  def add(items) when is_list(items) do
    Enum.each(items, &Storage.add(&1))
    "Added items to the shopping list."
  end

  def remove(msg) do
    item = sanitize(msg)
    :ok = Storage.remove(item)
    "#{item} was removed from the shopping list."
  end

  def get() do
    {:ok, items} = Storage.get()

    case Enum.uniq(items) do
      [] -> "There's nothing on the shopping list."
      i -> Enum.reduce(i, "Current shopping list:\n", fn item, acc -> acc <> item <> "\n" end)
    end
  end

  def clear() do
    :ok = Storage.clear()
    "Cleared the shopping list."
  end

  def sanitize(msg) do
    String.replace(msg, "/add ", "")
    |> String.trim()
  end
end
