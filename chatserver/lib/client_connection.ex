defmodule ClientConnection do
  import MessageSerializer
  require Logger
  @moduledoc """
  Abstraction used to simplify the use of the socket listening the client
  """
  @size_message_length 20
  @get_news_keyword "GET_NEWS"

  defp size_to_bytes_number(number) do
    String.pad_leading(Integer.to_string(number), @size_message_length, "0")
  end

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

  defp send_plain_text(socket, message) do
    padded_size = size_to_bytes_number(byte_size(message))
    :gen_tcp.send(socket, padded_size)
    :gen_tcp.send(socket, message)
  end

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

  def client_connection_run(socket, client_handler_pid, m_dispatcher_pid) do
    case read_plain_text_w_timeout(socket, 1) do
      {:ok, @get_news_keyword} ->
        send client_handler_pid, {:get_news, self()}
        receive do
          {:news, news} ->
            {:ok, encoded_news} = JSON.encode(news)
            send_plain_text(socket, encoded_news)
        end
      {:ok, data} ->
        {sender_id, recipient_id, text_message, timestamp, _} = deserialize_message(data)
        send m_dispatcher_pid, {:send_message, sender_id, recipient_id, text_message, timestamp}
        :ok
      :timeout ->
        :ok
      :error ->
        raise "Connection closed"
    end
    client_connection_run(socket, client_handler_pid, m_dispatcher_pid)
  end

end
