defmodule Server do

	def accept(port) do
		{:ok, socket} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
		IO.puts("Aceptando conexiones en el puerto #{port}")
		loop(socket)
  	end
	
	defp loop({:error, :closed}),do: :okboii
	defp loop(socket) do
		{:ok, socket} = :gen_tcp.accept(socket)
		serve(socket)
		loop(socket)
	end

	defp serve(socket) do
		socket
		|> read_line()
		|> write_line(socket)

		serve(socket)
	end

	defp read_line(socket) do
		{:ok, data} = :gen_tcp.recv(socket, 0)
		data
	end

	defp write_line(line, socket) do
		:gen_tcp.send(socket, line)
	end
end
