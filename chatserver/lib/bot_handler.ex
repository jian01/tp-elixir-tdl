defmodule ChatServer.BotHandler do
  use GenServer

  @moduledoc """
  GenServer responsible for handling bot state.
  """

  def get_text(numbers, guess_number, correct_number, sender_id) do
    if Map.has_key?(numbers, sender_id) do
      cond do
      guess_number < correct_number ->
        {"por debajo ..", numbers}
      guess_number > correct_number ->
        {"te pasaste ..", numbers}
      true ->
        numbers = Map.delete(numbers, sender_id)
        {"Ganaste!", numbers}
      end
    else
      numbers = Map.put(numbers, sender_id, Enum.random(1..10))
      {"El juego comienza: adivine el número", numbers}
    end
  end

  defprotocol NotificationInteractor do
    @doc """
    Dispatchs a notification by its type
    """
    @fallback_to_any true
    def answer_notification(notification, my_id, numbers)
  end

  defimpl NotificationInteractor, for: NewMessage do
    def answer_notification(notification, my_id, numbers) do
      received = notification.message
      sender_id = received.sender_id
      guess_number = String.to_integer(received.text)
      correct_number = Map.get(numbers, sender_id)
      {r_text, numbers} = ChatServer.BotHandler.get_text(numbers, guess_number, correct_number, sender_id)
      answer = %TextMessage{id: 0, sender_id: my_id, recipient_id: sender_id, text: r_text, timestamp: DateTime.utc_now() |> DateTime.to_iso8601()}
      processed_notification = %NewMessage{message: answer, recipient: sender_id}
      send ChatServer.MessageDispatcher, {:send_notification, processed_notification}
      {:ok, numbers}
    end
  end

  defimpl NotificationInteractor, for: Any do
    def answer_notification(_, _, numbers) do
      {:ok, numbers}
    end
  end


  ## Bot API

  @doc """
  Starts the handler.
  """
  def start_link(id: my_id) do
    {:ok, botpid} = GenServer.start_link(__MODULE__, my_id , [])
    ChatServer.HandlersMap.set(my_id, botpid)
    {:ok, botpid}
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
    numbers = %{}
    {:ok, {my_id, numbers}}
  end

  @impl true
  def handle_cast({:send_notif, notif}, {my_id, numbers}) do
    {:ok, numbers} = NotificationInteractor.answer_notification(notif, my_id, numbers)
    {:noreply, {my_id, numbers}}
  end

  @impl true
  def handle_cast({:get_notif, _}, {my_id, numbers}) do
    {:noreply, {my_id, numbers}}
  end

  @impl true
  def handle_cast({:ack_notif, _}, {my_id, numbers}) do
    {:noreply, {my_id, numbers}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end