defmodule Eightysix.ShoppingList.Storage do
  use GenServer
  defstruct [:path, :items]
  alias Eightysix.ShoppingList.Storage

  @impl true
  def init(path), do: {
      :ok,
      %Storage{
        path: path,
        items: []
      },
      {:continue, :load}
    }

  def start_link(path), do: GenServer.start_link(__MODULE__, path, name: __MODULE__)

  @impl true
  def terminate(_, %Storage{path: path, items: items}) do
    :ok = save(path, items)
  end

  @impl true
  def handle_continue(:load, %Storage{path: path} = state) do
    :ok = case File.read(path) do
      {:ok, binary} -> :erlang.binary_to_term(binary) |> Enum.each(&async_add/1)
      {:error, reason} -> IO.puts("Failed to read file #{path}: #{:file.format_error(reason)}")
    end
    {:noreply, state}
  end

  @impl true
  def handle_continue(:save, %Storage{path: path, items: items} = state) do
    :ok = save(path, items)
    {:noreply, state}
  end

  def save(path, items) do
    data = :erlang.term_to_binary(items)
    case File.write(path, data) do
      :ok -> :ok
      {:error, reason} -> IO.puts("Failed to write file #{path}: #{:file.format_error(reason)}")
    end
  end

  @impl true
  def handle_cast({:add, item}, %Storage{items: items} = state), do: {
      :noreply,
      %{state | items: [item | items]},
      {:continue, :save}
    }

  @impl true
  def handle_call({:add, item}, _, %Storage{items: items} = state), do: {
      :reply,
      :ok,
      %{state | items: [item | items]},
      {:continue, :save}
    }

  @impl true
  def handle_call({:get}, _, %Storage{items: items} = state), do: {
    :reply,
    {:ok, items},
    state
  }

  @impl true
  def handle_call({:clear}, _, state), do: {
    :reply,
    :ok,
    %{state | items: []},
    {:continue, :save}
  }

  def async_add(item) do
    GenServer.cast(__MODULE__, {:add, item})
  end

  def add(item) do
    GenServer.call(__MODULE__, {:add, item})
  end

  def get() do
    GenServer.call(__MODULE__, {:get})
  end

  def clear() do
    GenServer.call(__MODULE__, {:clear})
  end
end
