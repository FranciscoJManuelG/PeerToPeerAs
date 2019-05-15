defmodule ServerPeer do

	def accept(),do: accept(4000)
	def accept(port) do
		{:ok, serverSocket} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
		IO.puts("Aceptando conexiones en el puerto #{port}")
		loop(serverSocket)
  	end

	defp loop(serverSocket) do
		{:ok,clientSocket} = :gen_tcp.accept(serverSocket)
		spawn_link(__MODULE__,:serve,[clientSocket])
		loop(serverSocket)
	end

	def serve(socket) do
		socket
		|> read_line()
	end

	defp read_line(socket) do
		data = :gen_tcp.recv(socket, 0)
		see_resp(data,socket)
	end

	defp write_line(line, socket) do
		:gen_tcp.send(socket, line)
	end
	
	defp see_resp({:ok, data},socket) do
		#Para sacar el \n del final
		line = String.slice(String.trim(data),0,String.length(data)-1)
		#Aquí va la ip 
		{:ok, {{ip1,ip2,ip3,ip4}, port}} = :inet.peername(socket)
		#Paso la ip a un string
		ip = Kernel.inspect(ip1)<>"."<>Kernel.inspect(ip2)<>"."<>Kernel.inspect(ip3)<>"."<>Kernel.inspect(ip4)

		peticion = Kernel.inspect(Time.utc_now)<>"[#{ip}:#{port}]:\nP: #{data}"
		file = PeerInterface.execute(String.split(line))
		wantfile_resp(socket,file)

		#Almacena el log
		almacenar_log(peticion)

		IO.puts(peticion)
		serve(socket)
	end
	defp see_resp(_,_),do: :ok

	defp wantfile_resp(socket,file) do
		start = 0
		gap = 1024
		send_file(socket,start,gap,String.slice(file,start,gap),file)
	end

	defp send_file(socket,_,_,"",_),do: :gen_tcp.send(socket,"")
	defp send_file(socket,start,gap,msg,file) do 
		:gen_tcp.send(socket,msg)
		send_file(socket,start+gap,gap,String.slice(file,start+gap,gap),file)
	end

	defp almacenar_log(peticion) do
		File.write(Path.rootname(Utils.param(:log)), peticion<>"\n",[:append])
	end
end