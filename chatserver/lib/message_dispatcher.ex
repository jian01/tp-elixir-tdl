defmodule MessageDispatcher do
  require Logger
  @moduledoc """
  Module responsible for dispatching messages to clients
  """

  # Message dispatcher main loop
  defp main_loop() do
    receive do
      {:send_notification, notification} ->
        Logger.debug("Sending new to client #{notification.recipient}")
        if ChatServer.MappingAgent.exists(ChatServer.Clients, notification.recipient) do
          handler_pid = ChatServer.MappingAgent.get(ChatServer.Clients, notification.recipient)
          send handler_pid, {:send_notification, notification}
        end
        main_loop()
    end
  end

  @doc """
  Message dispatcher start point
  """
  def message_dispatcher_run() do
    main_loop()
  end

end
