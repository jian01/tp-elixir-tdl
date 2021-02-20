defmodule Constants do
  @moduledoc """
  Module used to define constants dynamically
  """


  @doc """
  Uses meta programming to define a macro that holds a constant value
  """
  defmacro const(const_name, const_value) do
    quote do
      defmacro unquote(const_name)(), do: unquote(const_value)
    end
  end
end
