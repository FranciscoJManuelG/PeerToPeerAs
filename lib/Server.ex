defmodule Server do
	import Interface

	def accept(port) do
		{:ok, socket} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
		IO.puts("Aceptando conexiones en el puerto #{port}")
		loop(socket)
  	end

	defp loop(socket) do
		{:ok,client} = :gen_tcp.accept(socket)
		pid = spawn_link(__MODULE__,:serve,[client])
		:gen_tcp.controlling_process(client,pid)
		#serve(client)
		loop(socket)
	end

	def serve(socket) do
		socket
		|> read_line()
		|> write_line(socket)
	end

	defp read_line(socket) do
		resp = :gen_tcp.recv(socket, 0)
		data = see_resp(resp)
		#Para sacar el \n del final
		data = String.slice(String.trim(data),0,String.length(data)-1)
		#Aquí va la ip 
		{:ok, {ip, port}} = :inet.peername(socket)
		{ip1,ip2,ip3,ip4} = ip
		#Paso la ip a un string
		ip = Kernel.inspect(ip1)<>"."<>Kernel.inspect(ip2)<>"."<>Kernel.inspect(ip3)<>"."<>Kernel.inspect(ip4)
		IO.puts(ip)
		IO.puts(Interface.execute(data, ip))
		Interface.execute(data, ip)		
	end

	defp see_resp({:ok, data}),do: data
	defp see_resp(_),do: :ok

	defp write_line(:ok, _),do: :ok
	defp write_line(line, socket) do
		:gen_tcp.send(socket, line)
		serve(socket)
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
