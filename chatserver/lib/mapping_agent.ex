defmodule MappingAgent do
  use Agent

  @doc """
  Create a mapping agent
  """
  def create() do
    Agent.start_link(fn -> %{} end)
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
