defmodule ClientHandler do
  @moduledoc """
  Responsible for handling client state
  """

  defp send_all_news(news, requester_pid) do
    send requester_pid, {:notifications, Enum.map(news, fn notification -> EntitySerializer.serialize(notification) end)}
  end

  defp main_loop(news) do
    receive do
      {:send_notification, notification} ->
        main_loop([notification | news])
      {:get_notifications, requester_pid} ->
        send_all_news(news, requester_pid)
        main_loop([])
    end
  end

  def client_handler_run() do
    main_loop([])
  end

end
