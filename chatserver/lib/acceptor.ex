defmodule ChatServer.Acceptor do
  use Task, restart: :transient
  require Logger

  @moduledoc """
  Acceptor for new clients.
  """

  @id_message_length 20


  def start_link(port: port) do
    Task.start_link(__MODULE__, :start_listening, [port])
  end

  # Registers client handler and starts client connection for `client`.
  defp register(client) do
    case :gen_tcp.recv(client, @id_message_length) do
      {:ok, data} ->
        {client_id, _} = Integer.parse(data)
        Logger.debug("Accepting new client with id #{client_id}")
        handler_pid = ChatServer.HandlersMap.get_or_set(client_id)
        {:ok, _} = Task.Supervisor.start_child(ChatServer.ConnectionsSupervisor, fn -> ChatServer.ClientConnection.client_connection_run(client, handler_pid) end)
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
    Process.register(self(), ChatServer.Acceptor)

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
