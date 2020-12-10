defmodule Eightysix.ShoppingList do
  alias Eightysix.ShoppingList.Storage

  def add(%{text: text}) do
    item = String.replace(text, "/add ", "")

    case String.trim(item) do
      "" ->
        "Please specify something to add, for example: /add rice"

      trimmed ->
        :ok = Storage.add(trimmed)
        "#{trimmed} was added to the shopping list."
    end
  end

  def get() do
    {:ok, items} = Storage.get()

    case items do
      [] -> "There's nothing on the shopping list"
      _ -> Enum.reduce(items, "Current shopping list:\n", fn item, acc -> acc <> item <> "\n" end)
    end
  end

  def clear() do
    :ok = Storage.clear()
    "Cleared the shopping list"
  end
end
