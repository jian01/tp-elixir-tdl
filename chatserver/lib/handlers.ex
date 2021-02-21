defmodule ChatServer.HandlersMap do
  use Agent

  @doc """
  Starts the registry.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Checks if client_id is in the registry.
  """
  def exists?(client_id) do
    Agent.get(__MODULE__, fn(state) ->
      Map.has_key?(state, client_id)
    end)
  end

  @doc """
  Gets pid for client_id.
  """
  def get(client_id) do
    Agent.get(__MODULE__, fn(state) ->
      Map.get(state, client_id)
    end)
  end

  @doc """
  If client_id is not in the registry, it is added.
  Returns the pid.
  """
  def get_or_set(client_id) do
    if __MODULE__.exists?(client_id) do
      __MODULE__.get(client_id)
    else
      {:ok, pid} = ChatServer.ClientHandler.start_link([])
      Agent.update(__MODULE__, fn(state) ->
        Map.put(state, client_id, pid)
      end)
      pid
    end
  end
end
