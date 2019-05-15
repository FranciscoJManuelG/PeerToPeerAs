defmodule Utils do

	############################## FUNCIONES AUXILIARES ###########################
	# Busca la id de una ip
	def idOfIp(ip,[{id,_,ip}|_]), do: id

	def idOfIp(ip,[_|tail]), do: idOfIp(ip,tail)

	def idOfIp(_,[]), do: :error

	######################################################
	# Busca si un nodo está :UP
	def nodeIsUpFunction(nodeId, [{nodeId,:UP,_}|_]), do: true
	
	def nodeIsUpFunction(nodeId, [{nodeId,:DOWN,_}|_]), do: false

	def nodeIsUpFunction(nodeId, [_|tail]), do: nodeIsUpFunction(nodeId, tail)

	def nodeIsUpFunction(_,_), do: false

	####################################################
	# Busca la ip correspondiente a un nodo
	def ipByNode(nodeId, [{nodeId,_, ip}|_]), do: ip

	def ipByNode(node, [_|tail]), do: ipByNode(node,tail)

	def ipByNode(_), do: "ERROR"

	####################################################
	# Busca una lista de nodos de un fichero
	def nodesByFile(fileId, [{fileId,hash,listNodes}|_]), do: {listNodes,hash}

	def nodesByFile(fileId, [_|tail]), do: nodesByFile(fileId, tail)

	def nodesByFile(_,_), do: {[],""}
 	####################################################
 	# Para saber si existe un nodo o un fichero
 	def exists(id, [{id, _, _}|_]), do: true

 	def exists(id, [_|tail]), do: exists(id, tail)

 	def exists(_,_), do: false
 	####################################################
	 # Para saber si existe un nodo o un fichero
	def addIfExists(file,hash,id,list), do: addIfExists(file,hash,id,list,[]) 

 	def addIfExists(file,hash,id,[{file, hash, ids}|t],aux), do: Enum.concat(aux,[{file, hash, [id | ids]}|t])  

 	def addIfExists(file,hash,id,[h|tail],aux), do: addIfExists(file,hash,id, [h | tail])

 	def addIfExists(_,_,_,_,aux), do: aux

	####################################################
	# Para eliminar un nodo
	def delete(id_node,list), do: delete(id_node,list,[])

	def delete(_,[],aux), do: aux

	def delete(id_node,[{id_node,_,_}|tail],aux), do:  Enum.concat(aux,tail)

	def delete(id_node,[node|tail],aux), do: delete(id_node, tail, [node | aux])

	############################################################
	# Modificar estado de un nodo
	def nodeStateFunction(nodeId, state, list), do:	
		nodeStateFunction(nodeId, state, list, [])

	def nodeStateFunction(nodeId, state, [{nodeId, _, ip}|tail], aux), do:
		Enum.concat(aux,[{nodeId, state, ip}|tail])

	def nodeStateFunction(node, status, [head|tail], aux), do:
		nodeStateFunction(node, status, tail, [head|aux])

	def nodeStateFunction(_, _, _, aux), do: aux

	#############################################################
	# Añade un nodo a un fichero
	def addNodeToFileFunction(fileId, hash, node, listFilesNodes), do:
		addNodeToFileFunction(fileId, hash, node, listFilesNodes, [])

	def addNodeToFileFunction(fileId, hash, node, [{fileId, hash, listNodes}|tail], listAux), do:
		Enum.concat(listAux, [{fileId, hash, [node | listNodes]} | tail])

	def addNodeToFileFunction(fileId, hash, node, [node|tail], listAux), do:
		addNodeToFileFunction(fileId, hash, node, tail, [node | listAux])

	def addNodeToFileFunction(_, _, [], listAux), do: listAux

	############################################################
	# Comprueba si el nodo esta en la lista
	def inList?(node, [node|_]), do: true		

	def inList?(node, [_|tail]), do: inList?(node,tail)

	def inList?(_, _), do: false
	############################################################
	def get_own_ip() do
		{:ok,list} = :inet.getif()
		get_own_ip(List.first(list))
	end
	def get_own_ip({{ip1,ip2,ip3,ip4},_,_}) do
		Kernel.inspect(ip1)<>"."<>Kernel.inspect(ip2)<>"."<>Kernel.inspect(ip3)<>"."<>Kernel.inspect(ip4)
	end
############################################################
	def param(:log) do
		#El log será la 1ª linea de configurations.conf
		case File.read("./lib/configurations.conf") do
		{:ok, data} -> path = Enum.at(String.split(data,"\n"),0)
						case File.exists?(path) do
							true -> path
							_ -> File.write(path,"")
								path
						end

		_ -> path = "./server_log"
						case File.exists?(path) do
							true -> path
						_ -> File.write(path,"")
							path
						end
		end
	end

	def param(:files) do
		#La carpeta de ficheros será la 2ª linea de configurations.conf
		case File.read("./lib/configurations.conf") do
			{:ok, data} -> path = Enum.at(String.split(data,"\n"),1)
							case File.exists?(path) do
								true -> path
								_ -> File.mkdir(path)
								path
							end
			_ -> path = "./ficheros/"
							case File.exists?(path) do
								true -> path
								_ -> File.mkdir(path)
								path
							end
			end
	end

	def param(:ip) do
		#La ip será la 3ª linea de configurations.conf
		case File.read("./lib/configurations.conf") do
			{:ok, data} -> Enum.at(String.split(data,"\n"),2)
			_ -> "127.0.0.1"
			end
	end

	def param(:port) do
		#La ip será la 4ª linea de configurations.conf
		case File.read("./lib/configurations.conf") do
			{:ok, data} -> Enum.at(String.split(data,"\n"),3)
			_ -> "5000"
			end
	end
end