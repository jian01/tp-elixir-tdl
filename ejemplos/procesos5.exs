defmodule Procesos do
  def saludador_de_amigos() do
    Process.sleep(2000)
    receive do
      :lauti ->
        IO.puts("Hola lauti :)")
      :mati ->
        IO.puts("Hola mati :)")
      :mauro ->
        IO.puts("Hola mauro cuando se rompen esas riki hamburguesas")
      _ ->
        raise "NO TE QUIERO >:("
    end
    saludador_de_amigos()
  end
end

pid_saludador = spawn_link fn -> Procesos.saludador_de_amigos() end

send pid_saludador, :juan
send pid_saludador, :mati
send pid_saludador, :mauro
send pid_saludador, :lauti
IO.puts("Enviados")
Process.sleep(99999999)
