defmodule ClientHandler do
  import NewNotification
  @moduledoc """
  Responsible for handling client state
  """

  @time_to_resend_notifications 20

  # Sends all news to a particular pid
  defp send_unacked_news(news, news_last_sent, requester_pid) do
    already_sent = Enum.filter(news_last_sent, fn {_, v} -> DateTime.diff(DateTime.utc_now(), v) < @time_to_resend_notifications end)
    already_sent = MapSet.new(Enum.map(already_sent, fn ({k, _}) -> k end))
    news = Enum.reject(news, fn {k, _} -> MapSet.member?(already_sent, k) end)
    send requester_pid, {:notifications, Enum.map(news, fn ({_, notification}) -> notification end)}
    timestamp_updates = Map.new(Enum.map(news, fn ({k, _}) -> {k, DateTime.utc_now()} end))

    news_last_sent = Map.merge(news_last_sent, timestamp_updates)
    news_last_sent
  end

  # Main loop of client handler
  defp main_loop(news, news_last_sent, notif_id) do
    receive do
      {:send_notification, notification} ->
        news = Map.put(news, notif_id, %NewNotification{id: notif_id, notification: notification, recipient: notification.recipient})
        main_loop(news, news_last_sent, notif_id + 1)
      {:get_notifications, requester_pid} ->
        news_last_sent = send_unacked_news(news, news_last_sent, requester_pid)
        main_loop(news, news_last_sent, notif_id)
      {:ack_notification, id} ->
        news = Map.new(Enum.reject(news, fn {k, _} -> k == id end))
        news_last_sent = Map.new(Enum.reject(news_last_sent, fn {k, _} -> k == id end))
        main_loop(news, news_last_sent, notif_id)
    end
  end

  @doc """
  Client handler start function
  """
  def client_handler_run() do
    main_loop(%{}, %{}, 0)
  end

end
