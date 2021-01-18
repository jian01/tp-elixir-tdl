defmodule ClientHandler do
  import MessageSerializer
  @moduledoc """
  Responsible for handling client state
  """

  defp send_all_news(news, requester_pid) do
    send requester_pid, {:news, Enum.map(news, fn {sender_id, recipient_id, content, timestamp} ->
      %{"type" => "new_message", "content" => serialize_message(sender_id, recipient_id, content, timestamp)} end)}
  end

  defp main_loop(news) do
    receive do
      {:new_message, sender_id, recipient_id, content, timestamp} ->
        main_loop([{sender_id, recipient_id, content, timestamp} | news])
      {:get_news, requester_pid} ->
        send_all_news(news, requester_pid)
        main_loop([])
    end
  end

  def client_handler_run() do
    main_loop([])
  end

end
