defmodule ClientConnectionHandler do
  require Logger
  @moduledoc """
  Contains the behaviour for handling the cliend opened connection
  """
  @size_message_length 20

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

  def handle_client_connection(socket, m_dispatcher_pid) do
    receive do
      {:send_message, message} ->
        Logger.debug("Sending message from handle_client_connection")
        padded_size = String.pad_leading(Integer.to_string(byte_size(message)), @size_message_length, "0")
        :gen_tcp.send(socket, padded_size)
        :gen_tcp.send(socket, message)
    after
      100 -> :ok
    end
    case :gen_tcp.recv(socket, @size_message_length, 1) do
      {:ok, data} ->
        {size_to_read, _} = Integer.parse(data)
        message = read_fixed_size(socket, size_to_read, "")
        {:ok, json_parsed} = JSON.decode(message)
        {destinatary_id, text_message} = {json_parsed["to"], json_parsed["message"]}
        send m_dispatcher_pid, {:send_message, destinatary_id, text_message}
        handle_client_connection(socket, m_dispatcher_pid)
      {:error, :closed} ->
        Logger.debug("Client closed their connection")
        :error
      {:error, :timeout} ->
        handle_client_connection(socket, m_dispatcher_pid)
      {:error, reason} ->
        Logger.info("Client openned socket error: #{inspect reason}")
        :error
    end
  end
end
