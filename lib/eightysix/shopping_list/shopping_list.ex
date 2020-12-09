defmodule Eightysix.ShoppingList do
  alias Eightysix.ShoppingList.Storage
  def add(%{text: text}) do
    item = String.replace(text, "/add ", "")
    :ok = Storage.add(item)
    "#{item} was added to the shopping list."
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
