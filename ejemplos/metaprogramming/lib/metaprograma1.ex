defmodule Metprograma1 do
  defmacro run1() do
    quote do
      defmacro sumar(a,b) do
        a+b
      end
    end
  end

  defmacro run2(multiplicador) do
    quote do
      defmacro sumar_especial(a,b) do
        (a+b)*unquote(multiplicador)
      end
    end
  end

  defmacro run3() do
    quote do
      defmacro sumar_especial2(a,b) do
        (a+b)*multiplicador()
      end
    end
  end
end
