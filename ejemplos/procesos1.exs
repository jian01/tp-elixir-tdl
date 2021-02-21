pid = spawn fn -> IO.puts("Hola mundo") end

IO.puts(Process.alive?(pid))
Process.sleep(100)
IO.puts(Process.alive?(pid))
IO.puts(Process.alive?(self()))
