defmodule ChatServer.Acceptor do
  import ClientConnection
  require Logger

  @moduledoc """
  Acceptor for new clients.
  """

  @id_message_length 20

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end


  def start_link(name: name) do
    pid = spawn_link fn -> start_listening(6500) end
    Process.register(pid, name)
    {:ok, pid}
  end

  # Registers client handler and starts client connection for `client`.
  defp register(client) do
    case :gen_tcp.recv(client, @id_message_length) do
      {:ok, data} ->
        {client_id, _} = Integer.parse(data)
        Logger.debug("Accepting new client with id #{client_id}")
        client_handler_pid = ChatServer.Handlers.set(ChatServer.Handlers, client_id)
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

  # Acceptor main loop.
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    :ok = register(client)
    loop_acceptor(socket)
  end

  @doc """
  Acceptor starting function.
  """
  def start_listening(port) do
    Logger.debug("Starting socket for listening new clients")
    case :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("Socket opened for listening")
        loop_acceptor(socket)

      {:error, reason} ->
        Logger.error("Could not open socket: #{reason}")
        :error
    end
  end

end
