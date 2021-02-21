defmodule ExecutionTime do
  def time_of(function) do
    {time, result} = :timer.tc(function)
    IO.puts "Time: #{time}ms"
    IO.puts "Result: #{result}"
  end
end

defmodule Procesos do
  def recibir_resultado() do
    receive do
      {:resultado, _, n} ->
        n
    end
  end

  def recibir_resultado_y_cachear(pid_cache, seek) do
    receive do
      {:resultado, seek, n} ->
        send pid_cache, {:resultado, seek, n}
        n
      {:resultado_cacheado, seek, n} ->
        n
    end
  end

  def fibonacci(padre, k) do
    case k do
      x when x == 0 ->
        send padre, {:resultado, k, 0}
      x when x == 1 ->
        send padre, {:resultado, k, 1}
      _ ->
        my_pid = self()
        spawn fn -> fibonacci(my_pid, k-1) end
        spawn fn -> fibonacci(my_pid, k-2) end
        total = recibir_resultado()
        total = total + recibir_resultado()
        send padre, {:resultado, k, total}
    end
  end

  def fibonacci_con_cache(padre, k, pid_cache) do
    case k do
      x when x == 0 ->
        send padre, {:resultado, k, 0}
      x when x == 1 ->
        send padre, {:resultado, k, 1}
      _ ->
        my_pid = self()
        send pid_cache, {:pedido, k-1, my_pid}
        send pid_cache, {:pedido, k-2, my_pid}
        spawn fn -> fibonacci(my_pid, k-1) end
        spawn fn -> fibonacci(my_pid, k-2) end
        total = recibir_resultado_y_cachear(pid_cache, k-1)
        total = total + recibir_resultado_y_cachear(pid_cache, k-2)
        send padre, {:resultado, k, total}
    end
  end

  def proceso_cache(cache) do
    receive do
      {:resultado, k, resultado} ->
        cache = Map.put(cache, k, resultado)
        proceso_cache(cache)
      {:pedido, k, pid} ->
        if Map.has_key?(cache, k) do
          send pid, {:resultado_cacheado, k, cache[k]}
        end
        proceso_cache(cache)
    end
  end
end

my_pid = self()

IO.puts("Fibonacci de 2")
_ = spawn fn -> Procesos.fibonacci(my_pid, 2) end
ExecutionTime.time_of(fn -> Procesos.recibir_resultado() end)

IO.puts("Fibonacci de 20")
_ = spawn fn -> Procesos.fibonacci(my_pid, 20) end
ExecutionTime.time_of(fn -> Procesos.recibir_resultado() end)

pid_cache = spawn fn -> Procesos.proceso_cache(%{}) end
IO.puts("Fibonacci de 20 con cache")
_ = spawn fn -> Procesos.fibonacci_con_cache(my_pid, 20, pid_cache) end
ExecutionTime.time_of(fn -> Procesos.recibir_resultado() end)

IO.puts("Fibonacci de 20 con cache")
_ = spawn fn -> Procesos.fibonacci_con_cache(my_pid, 20, pid_cache) end
ExecutionTime.time_of(fn -> Procesos.recibir_resultado() end)
