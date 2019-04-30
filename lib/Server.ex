defmodule Server do

	def accept(port) do
		{:ok, socket} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
		IO.puts("Aceptando conexiones en el puerto #{port}")
		loop(socket)
  	end

	defp loop(socket) do
		resp = :gen_tcp.accept(socket)
		Task.start_link(__MODULE__,:serve,[resp])
		#serve(client)
		loop(socket)
	end

	def serve({:ok,socket}) do
		socket
		|> read_line()
		|> write_line(socket)

		serve(socket)
	end
	def serve(_),do: :ok

	defp read_line({:error,:closed}),do: :ok
	defp read_line(socket) do
		{:ok, data} = :gen_tcp.recv(socket, 0)
		data
	end

	defp write_line(line, socket) do
		:gen_tcp.send(socket, line)
	end
end


#SERVER
#{:ok, socket}=:gen_tcp.listen(5000,[:binary,
#	 packet: :line, active: false, reuseaddr: true])
#{:ok, client} = :gen_tcp.accept(socket)
#{:ok, data} = :gen_tcp.recv(client, 0)
#:gen_tcp.send(client, line)

#CLIENT
#{:ok,socket} = :gen_tcp.connect('127.0.0.1',5000,[:binary,
#	packet: :line, active: false, reuseaddr: true])
#:gen_tcp.send(socket,"holahola")
#{:ok, data} = :gen_tcp.recv(socket, 0)
