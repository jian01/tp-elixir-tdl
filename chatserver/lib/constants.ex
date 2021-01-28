defmodule Constants do
  defmacro __using__(_opts) do
     quote do
       import Constants
     end
   end

  defmacro const(const_name, const_value) do
    quote do
      defmacro unquote(const_name)(), do: unquote(const_value)
    end
  end
end
