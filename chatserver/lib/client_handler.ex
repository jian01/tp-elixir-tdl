defmodule ChatServer.ClientHandler do
  use GenServer

  @moduledoc """
  GenServer responsible for handling client state.
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

  ## Client API

  @doc """
  Starts the handler.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end


  @doc """
  TODO
  """
  def send_notif(server, notif) do
    GenServer.cast(server, {:send_notif, notif})
  end

  @doc """
  TODO
  """
  def get_notif(server, requester_pid) do
    GenServer.cast(server, {:get_notif, requester_pid})
  end

  @doc """
  TODO
  """
  def ack_notif(server, id) do
    GenServer.cast(server, {:ack_notif, id})
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    news = %{}
    news_last_sent = %{}
    notif_id = 0
    {:ok, {news, news_last_sent, notif_id}}
  end

  @impl true
  def handle_cast({:send_notif, notif}, {news, news_last_sent, notif_id}) do
    news = Map.put(news, notif_id, %NewNotification{id: notif_id, notification: notif, recipient: notif.recipient})
    {:noreply, {news, news_last_sent, notif_id + 1}}
  end

  @impl true
  def handle_cast({:get_notif, requester_pid}, {news, news_last_sent, notif_id}) do
    news_last_sent = send_unacked_news(news, news_last_sent, requester_pid)
    {:noreply, {news, news_last_sent, notif_id}}
  end

  @impl true
  def handle_cast({:ack_notif, id}, {news, news_last_sent, notif_id}) do
    news = Map.new(Enum.reject(news, fn {k, _} -> k == id end))
    news_last_sent = Map.new(Enum.reject(news_last_sent, fn {k, _} -> k == id end))
    {:noreply, {news, news_last_sent, notif_id}}
  end

  @impl true
  def handle_info(_msg, handlers) do
    {:noreply, handlers}
  end
end
