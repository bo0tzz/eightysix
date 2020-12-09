defmodule Eightysix.ShoppingList do
  alias Eightysix.ShoppingList.Storage
  def add(msg) do
    :ok = Storage.add(msg)
    "#{msg} was added to the shopping list."
  end

  def get() do
    {:ok, items} = Storage.get()
    Enum.reduce(items, "Current shopping list:\n", fn item, acc -> acc <> item <> "\n" end)
  end

  def clear() do
    :ok = Storage.clear()
    "Cleared the shopping list"
  end
end
