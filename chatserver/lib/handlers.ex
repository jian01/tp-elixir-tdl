defmodule ChatServer.HandlersMap do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  If client_id is not in the registry, it is added.
  Returns the pid.
  """
  def set(server, client_id) do
    GenServer.call(server, {:set, client_id})
  end

  @doc """
  Checks if client_id is in the registry.
  """
  def exists?(server, client_id) do
    GenServer.call(server, {:exists?, client_id})
  end

  @doc """
  Gets pid for client_id in server.
  """
  def get(server, client_id) do
    GenServer.call(server, {:get, client_id})
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    handlers = %{}
    {:ok, handlers}
  end

  @impl true
  def handle_call({:set, client_id}, _from, handlers) do
    if Map.has_key?(handlers, client_id) do
      {:ok, pid} = Map.fetch(handlers, client_id)
      {:reply, pid, handlers}
    else
      {:ok, pid} = ChatServer.ClientHandler.start_link([])
      handlers = Map.put(handlers, client_id, pid)
      {:reply, pid, handlers}
    end
  end

  @impl true
  def handle_call({:exists?, client_id}, _from, handlers) do
    {:reply, Map.has_key?(handlers, client_id), handlers}
  end

  @impl true
  def handle_call({:get, client_id}, _from, handlers) do
    {:ok, pid} = Map.fetch(handlers, client_id)
    {:reply, pid, handlers}
  end

  @impl true
  def handle_info(_msg, handlers) do
    {:noreply, handlers}
  end
end
