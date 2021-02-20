defmodule ChatServer do
  use Application

  @impl true
  def start(_type, _args) do
    ChatServer.Supervisor.start_link(name: ChatServer.Supervisor)
  end
end
