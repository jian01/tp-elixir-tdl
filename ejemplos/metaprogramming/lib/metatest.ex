defmodule MetaTest do
  import Metprograma1
  @moduledoc """
  Documentation for `Meta`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Meta.hello()
      :world

  """
  defmacro multiplicador() do
    3
  end

  run1()
  run2(3)
  run3()

  def start(_,_) do
    IO.puts(sumar(1,2))
    IO.puts(sumar_especial(1,2))
    IO.puts(sumar_especial2(1,2))
    {:ok, self()}
  end
end
