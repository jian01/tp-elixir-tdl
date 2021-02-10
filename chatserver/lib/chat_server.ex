defmodule ChatServer do
  import ChatServerListener
  @moduledoc """
  Chat server main module and launcher
  """

  @doc """
  Chat server start function
  """
  def start(_type, _args) do
    start_listening()

    {:ok, self()}
  end

end
