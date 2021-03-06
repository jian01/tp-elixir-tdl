defmodule ChatServer.ClientConnection do
  use Task
  require Logger
  import EntityDeserializer
  import NotificationAck
  import NewMessage


  @moduledoc """
  Abstraction used to simplify the use of the socket listening the client.
  """

  @size_message_length 20

  defprotocol NotificationDispatcher do
    @doc """
    Dispatchs a notification by its type
    """
    @fallback_to_any true
    def dispatch_notification(notification, socket, client_handler_pid)
  end

  defimpl NotificationDispatcher, for: NotificationAck do
    def dispatch_notification(notification, _, client_handler_pid) do
      ChatServer.ClientHandler.ack_notif(client_handler_pid, notification.notification_id)
    end
  end

  defimpl NotificationDispatcher, for: NewMessage do
    def dispatch_notification(notification, _, _) do
      preprocessed_message = MessagePreprocessor.preprocess(notification.message)
      preprocessed_notification = %NewMessage{message: preprocessed_message, recipient: notification.recipient}
      send ChatServer.MessageDispatcher, {:send_notification, preprocessed_notification}
    end
  end

  defimpl NotificationDispatcher, for: Any do
    def dispatch_notification(notification, _, _) do
      send ChatServer.MessageDispatcher, {:send_notification, notification}
    end
  end

  # Converts an integer to a fixed size string of size @size_message_length
  defp size_to_bytes_number(number) do
    String.pad_leading(Integer.to_string(number), @size_message_length, "0")
  end

  # Reads a fixed size amount of bytes from the socket. Locks until all bytes are read.
  defp read_fixed_size(socket, size_to_read, buffer) do
    case :gen_tcp.recv(socket, size_to_read) do
      {:ok, data} ->
        case byte_size(data) do
          read_size when read_size == size_to_read ->
            buffer <> data
          read_size ->
            buffer <> read_fixed_size(socket, size_to_read - read_size, buffer)
        end
      {:error, reason} ->
        Logger.info("Failed read fixed size: #{inspect reason}")
    end
  end

  # Sends plain text through the socket
  defp send_plain_text(socket, message) do
    padded_size = size_to_bytes_number(byte_size(message))
    :gen_tcp.send(socket, padded_size)
    :gen_tcp.send(socket, message)
  end

  # Reads plain text from the socket using a timeout, 0 for no timeout
  defp read_plain_text_w_timeout(socket, timeout) do
    case :gen_tcp.recv(socket, @size_message_length, timeout) do
      {:ok, data} ->
        {size_to_read, _} = Integer.parse(data)
        message = read_fixed_size(socket, size_to_read, "")
        {:ok, message}

      {:error, :closed} ->
        Logger.debug("Client closed their connection")
        :error

      {:error, :timeout} ->
        :timeout

      {:error, reason} ->
        Logger.error("Client openned socket error: #{inspect reason}")
        :error
    end
  end

  @doc """
  Client connection main loop
  """
  def client_connection_run(socket, client_handler_pid) do
    case read_plain_text_w_timeout(socket, 1) do
      {:ok, data} ->
        notification = deserialize_notification(data)
        NotificationDispatcher.dispatch_notification(notification, socket, client_handler_pid)

      :timeout ->
        :ok

      :error ->
        exit(0)
    end

    ChatServer.ClientHandler.get_notif(client_handler_pid, self())

    receive do
      {:notifications, notifications} ->
        Enum.each notifications, fn notification ->
          notification = EntitySerializer.serialize(notification)
          send_plain_text(socket, notification)
        end
    end
    client_connection_run(socket, client_handler_pid)
  end

end
