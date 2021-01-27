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
      {:send_new, type, content_tuple, recipient} ->
        Logger.debug("Sending new to client #{recipient} of type #{type}")
        handler_pid = Map.get(client_handlers_map, recipient)
        send handler_pid, {:send_new, type, content_tuple, recipient}
        main_loop(client_handlers_map)
      {:send_message, id, sender_id, recipient_id, content, timestamp} ->
        Logger.debug("Sending message in MessageDispatcher from #{sender_id} to #{recipient_id}")
        handler_pid = Map.get(client_handlers_map, recipient_id)
        send handler_pid, {:new_message, id, sender_id, recipient_id, content, timestamp}
        main_loop(client_handlers_map)
    end
  end

  def message_dispatcher_run() do
    main_loop(%{})
  end

end
