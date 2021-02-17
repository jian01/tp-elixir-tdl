defmodule ChatServer.MessageDispatcher do
  require Logger

  @moduledoc """
  Module responsible for dispatching messages to clients.
  """

  @doc """
  Child spec for supervisor to run it.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Starts message dispatcher.
  """
  def start_link(name: name) do
    pid = spawn_link fn -> main_loop() end
    Process.register(pid, name)
    {:ok, pid}
  end

  # Message dispatcher main loop
  defp main_loop() do
    receive do
      {:send_notification, notification} ->
        Logger.debug("Sending new to client #{notification.recipient}")
        if ChatServer.Handlers.exists?(ChatServer.Handlers, notification.recipient) do
          handler_pid = ChatServer.Handlers.get(ChatServer.Handlers, notification.recipient)
          ChatServer.ClientHandler.send_notif(handler_pid, notification)
          # send handler_pid, {:send_notif, notification}
        end
        main_loop()
    end
  end

end
