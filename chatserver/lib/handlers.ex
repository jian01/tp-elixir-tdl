defmodule ChatServer.Handlers do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  TODO
  """
  def set(server, client_id) do
    GenServer.call(server, {:set, client_id})
  end

  @doc """
  TODO
  """
  def exists?(server, client_id) do
    GenServer.call(server, {:exists?, client_id})
  end

  @doc """
  TODO
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
      # TODO:
      # {:ok, pid} = DynamicSupervisor.start_child(ChatServer.ClientsSupervisor, ?)

      pid = spawn_link fn -> ChatServer.ClientHandler.client_handler_run() end
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
