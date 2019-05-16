defmodule Server do

	def accept(),do: accept(5000)
	def accept(port) do
		case :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true]) do
			{:ok, serverSocket} -> IO.puts("Aceptando conexiones en el puerto #{port}")
									loop(serverSocket)
			_ -> IO.puts("Error al iniciar el servidor")
		end
  	end

	defp loop(serverSocket) do
		case :gen_tcp.accept(serverSocket) do
			{:ok,clientSocket} -> _pid = spawn_link(__MODULE__,:serve,[clientSocket])
									loop(serverSocket)
			_ -> IO.puts("Error al aceptar la conexion")
		end
	end

	def serve(socket) do
		socket
		|> read_line()
		|> write_line(socket)
	end

	defp read_line(socket) do
		data = :gen_tcp.recv(socket, 0)
		see_resp(data,socket)
	end

	defp write_line(:ok, _),do: :ok
	defp write_line(line, socket) do
		:gen_tcp.send(socket, line)
		serve(socket)
	end
	
	defp see_resp({:ok, data},socket) do
		#Para sacar el \n del final
		line = String.slice(String.trim(data),0,String.length(data)-1)
		#Aquí va la ip 
		{:ok, {{ip1,ip2,ip3,ip4}, port}} = :inet.peername(socket)
		#Paso la ip a un string
		ip = Kernel.inspect(ip1)<>"."<>Kernel.inspect(ip2)<>"."<>Kernel.inspect(ip3)<>"."<>Kernel.inspect(ip4)

		peticion = Kernel.inspect(Time.utc_now)<>"[#{ip}:#{port}]:\nP: #{data}"
		respuesta = "R: "<>Interface.execute(line, ip)<>"\n"

		#Almacena el log
		almacenar_log(peticion, respuesta)

		IO.puts(peticion<>respuesta)
		respuesta
	end
	defp see_resp(_,_),do: :ok

	defp almacenar_log(peticion, respuesta) do
		File.write(Path.rootname(Utils.param(:log)), peticion<>respuesta<>"\n",[:append])
	end
end