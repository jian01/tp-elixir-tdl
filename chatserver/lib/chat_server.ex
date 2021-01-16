defmodule ChatServer do
  import ChatServerListener
  @moduledoc """
  Chat server main module and launcher
  """

  @doc """
  Chat server start function
  """
  def start(_type, _args) do
    pid = spawn fn -> start_listening() end

    {:ok, pid}
  end

end
