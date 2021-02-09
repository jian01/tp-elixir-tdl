defmodule ClientHandler do
  import NewNotification
  @moduledoc """
  Responsible for handling client state
  """

  # Sends all news to a particular pid
  defp send_all_news(news, requester_pid) do
    send requester_pid, {:notifications, Enum.map(news, fn notification -> EntitySerializer.serialize(%NewNotification{id: 1, notification: notification, recipient: notification.recipient}) end)}
  end

  # Main loop of client handler
  defp main_loop(news) do
    receive do
      {:send_notification, notification} ->
        main_loop([notification | news])
      {:get_notifications, requester_pid} ->
        send_all_news(news, requester_pid)
        main_loop([])
    end
  end

  @doc """
  Client handler start function
  """
  def client_handler_run() do
    main_loop([])
  end

end
