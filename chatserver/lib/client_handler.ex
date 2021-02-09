defmodule ClientHandler do
  import NewNotification
  @moduledoc """
  Responsible for handling client state
  """

  # Sends all news to a particular pid
  defp send_all_news(news, requester_pid) do
    send requester_pid, {:notifications, Enum.map(news, fn ({_, notification}) -> EntitySerializer.serialize(notification) end)}
  end

  # Main loop of client handler
  defp main_loop(news, notif_id) do
    receive do
      {:send_notification, notification} ->
        news = Map.put(news, notif_id, %NewNotification{id: notif_id, notification: notification, recipient: notification.recipient})
        main_loop(news, notif_id + 1)
      {:get_notifications, requester_pid} ->
        send_all_news(news, requester_pid)
        main_loop(news, notif_id)
    end
  end

  @doc """
  Client handler start function
  """
  def client_handler_run() do
    main_loop(%{}, 0)
  end

end
