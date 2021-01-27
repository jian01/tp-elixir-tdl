defmodule ClientHandler do
  import NewSerializer
  @moduledoc """
  Responsible for handling client state
  """

  defp send_all_news(news, requester_pid) do
    send requester_pid, {:news, Enum.map(news, fn {type, content, recipient} ->
      serialize_new(type, content, recipient) end)}
  end

  defp main_loop(news) do
    receive do
      {:send_new, type, content_tuple, recipient} ->
        main_loop([{type, content_tuple, recipient} | news])
      {:new_message, id, sender_id, recipient_id, content, timestamp} ->
        main_loop([{"new_message", {id, sender_id, recipient_id, content, timestamp}, recipient_id} | news])
      {:get_news, requester_pid} ->
        send_all_news(news, requester_pid)
        main_loop([])
    end
  end

  def client_handler_run() do
    main_loop([])
  end

end
