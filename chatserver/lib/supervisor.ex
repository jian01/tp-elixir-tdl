defmodule ChatServer.Supervisor do
  use Supervisor

  @moduledoc """
  ChatServer main supervisor.
  """

  @doc """
  Starts the supervisor.
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  `init` callback for supervisor.
  """
  @impl true
  def init(:ok) do
    children = [
      # Dynamic Supervisors
      #{DynamicSupervisor, name: ChatServer.ClientsSupervisor, strategy: :one_for_one},

      # ClientHandlers register
      #{Registry, keys: :unique, name: ChatServer.Registry},

      # GenServers
      {ChatServer.Handlers, name: ChatServer.Handlers},
      {ChatServer.MessageDispatcher, name: ChatServer.MessageDispatcher},

      # Acceptor main loop
      {ChatServer.Acceptor, name: ChatServer.Acceptor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
