defmodule ChatServer.BotHandler do
  use GenServer

  @moduledoc """
  GenServer responsible for handling bot state.
  """


  defprotocol NotificationInteractor do
    @doc """
    Dispatchs a notification by its type
    """
    @fallback_to_any true
    def answer_notification(notification, my_id)
  end

  defimpl NotificationInteractor, for: NewMessage do
    def answer_notification(notification, my_id) do
      sender_id = notification.message.sender_id
      message = %TextMessage{id: 0, sender_id: my_id, recipient_id: sender_id, text: "hola", timestamp: DateTime.utc_now() |> DateTime.to_iso8601()}
      processed_notification = %NewMessage{message: message, recipient: sender_id}
      send ChatServer.MessageDispatcher, {:send_notification, processed_notification}
    end
  end

  defimpl NotificationInteractor, for: Any do
    def answer_notification(_, _) do
      :ok
    end
  end


  ## Bot API

  @doc """
  Starts the handler.
  """
  def start_link(my_id, opts) do
    GenServer.start_link(__MODULE__, my_id, opts)
  end


  @doc """
  Send notification wrapper.
  """
  def send_notif(server, notif) do
    GenServer.cast(server, {:send_notif, notif})
  end

  ## Server callbacks

  @impl true
  def init(my_id) do
    my_id = my_id
    {:ok, my_id}
  end

  @impl true
  def handle_cast({:send_notif, notif}, my_id) do
    NotificationInteractor.answer_notification(notif, my_id)
    {:noreply, my_id}
  end

  @impl true
  def handle_cast({:get_notif, _}, my_id) do
    {:noreply, my_id}
  end

  @impl true
  def handle_cast({:ack_notif, _}, my_id) do
    {:noreply, my_id}
  end

  @impl true
  def handle_info(_msg, handlers) do
    {:noreply, handlers}
  end
end