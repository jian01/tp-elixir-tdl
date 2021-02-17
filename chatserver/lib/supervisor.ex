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
      {Task.Supervisor, name: ChatServer.ConnectionsSupervisor},
      {ChatServer.Handlers, name: ChatServer.Handlers},
      {ChatServer.MessageDispatcher, name: ChatServer.MessageDispatcher},
      {ChatServer.Acceptor, port: 6500}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
