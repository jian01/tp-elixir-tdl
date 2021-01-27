defmodule MessageDispatcher do
  require Logger
  @moduledoc """
  Module responsible for dispatching messages to clients
  """

  defp main_loop(client_handlers_map) do
    receive do
      {:add_client, client_id,handler_pid} ->
        Logger.debug("Adding client #{client_id} to map")
        client_handlers_map = Map.put(client_handlers_map, client_id, handler_pid)
        main_loop(client_handlers_map)
      {:send_notification, notification} ->
        Logger.debug("Sending new to client #{notification.recipient} of type #{notification.type}")
        handler_pid = Map.get(client_handlers_map, notification.recipient)
        send handler_pid, {:send_notification, notification}
        main_loop(client_handlers_map)
    end
  end

  def message_dispatcher_run() do
    main_loop(%{})
  end

end
