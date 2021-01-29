defmodule ChatServerListener do
  import ClientConnection
  import ClientHandler
  import MessageDispatcher
  require Logger
  @moduledoc """
  Chat server connection listener for clients, acts as supervisor.
  """
  @id_message_length 20

  @doc """
  Responsible for accepting the connection of a new client
  """
  def accept_connection(socket, m_dispatcher_pid, client_handlers_map_pid) do
    {:ok, client} = :gen_tcp.accept(socket)
    case :gen_tcp.recv(client, @id_message_length) do
      {:ok, data} ->
        {client_id, _} = Integer.parse(data)
        Logger.debug("Accepting new client with id #{client_id}")
        client_handler_pid = if MappingAgent.exists(client_handlers_map_pid, client_id) do
          MappingAgent.get(client_handlers_map_pid, client_id)
        else
          pid = spawn_link fn -> client_handler_run() end
          MappingAgent.put(client_handlers_map_pid, client_id, pid)
          pid
        end
        _ = spawn fn -> client_connection_run(client, client_handler_pid, m_dispatcher_pid) end
        accept_connection(socket, m_dispatcher_pid, client_handlers_map_pid)
      {:error, :closed} ->
        Logger.debug("Client closed their connection")
        :error
      {:error, reason} ->
        Logger.info("Client openned socket error: #{inspect reason}")
        :error
    end
  end

  @doc """
  Responsible for opening the socket
  """
  def start_listening() do
    {:ok, client_handlers_map_pid} = MappingAgent.create()
    m_dispatcher_pid = spawn_link fn ->
      message_dispatcher_run(client_handlers_map_pid)
    end
    Logger.debug("Starting socket for listening new clients")
    case :gen_tcp.listen(6500, [:binary, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("Socket opened for listening")
        accept_connection(socket, m_dispatcher_pid, client_handlers_map_pid)
      {:error, reason} ->
        Logger.error("Could not open socket: #{reason}")
    end
  end

end
