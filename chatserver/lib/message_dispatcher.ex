defmodule MessageDispatcher do
  require Logger
  @moduledoc """
  Module responsible for dispatching messages to clients
  """

  # Message dispatcher main loop
  defp main_loop(client_handlers_map_pid) do
    receive do
      {:send_notification, notification} ->
        Logger.debug("Sending new to client #{notification.recipient}")
        handler_pid = MappingAgent.get(client_handlers_map_pid, notification.recipient)
        send handler_pid, {:send_notification, notification}
        main_loop(client_handlers_map_pid)
    end
  end

  @doc """
  Message dispatcher start point
  """
  def message_dispatcher_run(client_handlers_map_pid) do
    main_loop(client_handlers_map_pid)
  end

end
