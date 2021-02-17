defmodule ChatServer.MappingAgent do
  use Agent
  require Logger

  @doc """
  Starts a new mapping agent.
  """
  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end


  @doc """
  Gets a value from the map.
  """
  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  @doc """
  Puts the value for the given key in the map.
  """
  def put(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  @doc """
  Check if a key exists in the mapping.
  """
  def exists(pid, key) do
    value = Agent.get(pid, &Map.get(&1, key))
    case value do
      :nil ->
        false
      _ ->
        true
    end
  end
end
