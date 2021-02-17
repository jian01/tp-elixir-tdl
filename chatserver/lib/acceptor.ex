defmodule ChatServer.Acceptor do
  import ClientConnection
  import ClientHandler
  require Logger

  @moduledoc """
  Accepter for new clients.
  """

  @id_message_length 20

  @doc """
  Child spec for supervisor to run it.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Starts a new acceptor.
  """
  def start_link(_opts) do
    start_listening()
  end

  defp register(client) do
    case :gen_tcp.recv(client, @id_message_length) do
      {:ok, data} ->
        {client_id, _} = Integer.parse(data)
        Logger.debug("Accepting new client with id #{client_id}")
        client_handler_pid = if ChatServer.MappingAgent.exists(ChatServer.Clients, client_id) do
          ChatServer.MappingAgent.get(ChatServer.Clients, client_id)
        else
          pid = spawn_link fn -> client_handler_run() end
          ChatServer.MappingAgent.put(ChatServer.Clients, client_id, pid)
          pid
        end
        _ = spawn fn -> client_connection_run(client, client_handler_pid) end
        :ok

      {:error, :closed} ->
        Logger.debug("Client closed their connection")
        :error

      {:error, reason} ->
        Logger.info("Client openned socket error: #{inspect reason}")
        :error
    end
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    :ok = register(client)
    loop_acceptor(socket)
  end

  defp start_listening() do
    Logger.debug("Starting socket for listening new clients")
    case :gen_tcp.listen(6500, [:binary, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("Socket opened for listening")
        loop_acceptor(socket)

      {:error, reason} ->
        Logger.error("Could not open socket: #{reason}")
    end
  end

end
