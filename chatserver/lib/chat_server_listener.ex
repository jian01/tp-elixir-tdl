defmodule ChatServerListener do
  import ClientConnection
  import ClientHandler
  import MessageDispatcher
  require Logger
  @moduledoc """
  Chat server connection listener for clients, acts as supervisor.
  """
  @id_message_length 20

  def accept_connection(socket, m_dispatcher_pid) do
    {:ok, client} = :gen_tcp.accept(socket)
    case :gen_tcp.recv(client, @id_message_length) do
      {:ok, data} ->
        {client_id, _} = Integer.parse(data)
        Logger.debug("Accepting new client with id #{client_id}")
        client_handler_pid = spawn fn -> client_handler_run() end
        send m_dispatcher_pid, {:add_client, client_id, client_handler_pid}
        _ = spawn fn -> client_connection_run(client, client_handler_pid, m_dispatcher_pid) end
        accept_connection(socket, m_dispatcher_pid)
      {:error, :closed} ->
        Logger.debug("Client closed their connection")
        :error
      {:error, reason} ->
        Logger.info("Client openned socket error: #{inspect reason}")
        :error
    end
  end

  def start_listening() do
    m_dispatcher_pid = spawn_link fn ->
      message_dispatcher_run()
    end
    Logger.debug("Starting socket for listening new clients")
    case :gen_tcp.listen(6500, [:binary, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("Socket opened for listening")
        accept_connection(socket, m_dispatcher_pid)
      {:error, reason} ->
        Logger.error("Could not open socket: #{reason}")
    end
  end

end
