defmodule MessageDispatcher do
  require Logger
  @moduledoc """
  Module responsible for dispatching messages to clients
  """

  defp main_loop(connections_map) do
    receive do
      {:add_client, client_id,handler_pid} ->
        Logger.debug("Adding client #{client_id} to map")
        connections_map = Map.put(connections_map, client_id, handler_pid)
        main_loop(connections_map)
      {:send_message, client_id, message} ->
        Logger.debug("Sending message from main_loop to #{client_id}")
        handler_pid = Map.get(connections_map, client_id)
        send handler_pid, {:send_message, message}
        main_loop(connections_map)
    end
  end

  def message_dispatcher_run() do
    main_loop(%{})
  end

end
