test:
	(cd chatserver && mix deps.get)
	(cd chatserver && mix compile)
	(cd chatserver && elixir --erl "-detached" -S mix run --no-halt)
	sleep 10
	python3 ./python_client/test_chatserver.py
	pkill -f erlang

test_travis:
	(cd chatserver && mix deps.get)
	(cd chatserver && mix compile)
	(cd chatserver && elixir --erl "-detached" -S mix run --no-halt)
	sleep 10
	python3 ./python_client/test_chatserver.py
