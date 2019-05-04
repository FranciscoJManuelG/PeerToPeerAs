defmodule ServerWIP do
	use GenServer
	#Client
  	def addNode(node, ip) do
  		IO.puts("Añadiendo nodo base con id '#{node}' e ip '#{ip}'.")
  		GenServer.cast(:server, {:addNode, node, ip})
  	end

  	def addNodeM(nodeM, ip) do
  		IO.puts("Añadiendo nodo maestro con id '#{nodeM}' e ip '#{ip}'.")
  		GenServer.cast(:server, {:addNodeM, nodeM, ip})
  	end

  	def addFile(fileId, file) do
  		IO.puts("Añadiendo fichero con id '#{fileId}'")
  		GenServer.cast(:server, {:addFile, fileId, file})
  	end

  	def viewAll() do
		GenServer.call(:server, :viewAll)
	end

  	def viewNodes() do
  		IO.puts("Mostrando la estructura de los nodos base")
		GenServer.call(:server, :viewNodes)
	end

	def viewNodesM() do
		IO.puts("Mostrando la estructura de los nodo maestros")
		GenServer.call(:server, :viewNodesM)
	end

	def viewFiles() do
		IO.puts("Mostrando la estructura de los ficheros con los nodos asociados")
		GenServer.call(:server, :viewFiles)
	end

	def removeNode(node) do
		IO.puts("Eliminando nodo base '#{node}'")
		GenServer.cast(:server, {:removeNode, node})
	end

	def removeNodeM(nodeM) do
		IO.puts("Eliminando nodo maestro '#{nodeM}'")
		GenServer.cast(:server, {:removeNodeM, nodeM})
	end

	def removeFile(file) do
		IO.puts("Eliminando fichero '#{file}'")
		GenServer.cast(:server, {:removeFile, file})
	end

	def nodeUp(node) do
		IO.puts("Estableciendo nodo base como activo '#{node}'")
  		GenServer.cast(:server, {:nodeUp, node})
  	end

  	def nodeDown(node) do
  		IO.puts("Estableciendo nodo base como apagado '#{node}'")
  		GenServer.cast(:server, {:nodeDown, node})
  	end
  	#list?
  	def nodeMSync(nodeM, listSync) do
  		IO.puts("Sincronizando nodo maestro '#{nodeM}'")
  		GenServer.cast(:server, {:nodeMSync, nodeM, listSync})
  	end

	def addNodeToFile(file, node) do
		IO.puts("Añadiendo '#{node}' al fichero '#{file}'")
		GenServer.cast(:server, {:addNodeToFile, file, node})
	end

	def removeNodeOfFile(file, node) do
		IO.puts("Eliminando '#{node}' del fichero '#{file}'")
		GenServer.cast(:server, {:removeNodeOfFile, file, node})
	end

	def offer(fileId, file, node) do
		addFile(fileId, file)
		addNodeToFile(fileId,node)
	end

	def want(fileId) do
		IO.puts("Mostrando ip de donde se debe descargar el fichero '#{fileId}'")
		GenServer.call(:server, {:viewFile, fileId})
	end

	def isNodeUp(name) do
		GenServer.call(:server, {:nodeIsUp, name})
	end

	def idOfIp(ip) do
		GenServer.call(:server, {:idOfIp, ip})
	end

	def isAdmin(ip) do
		#De momento siempre devuelve true solo si es localhost
		ip == "127.0.0.1"
	end
	#Server

	#Arranca el servidor
	def start() do
    	{:ok, pid} = GenServer.start_link(__MODULE__, [[],[],[]])
    	Process.register(pid,:server)
    	:ok
  	end

    # handle the trapped exit call
    def stop() do
    	GenServer.stop(:server)
    end

  	#Muestra la estructura completa
	def handle_call(:viewAll, _from, list) do
		#Se devuelve la estructura almacenada en el nodo
		{:reply, list, list}
	end

	#Muestra los nodos básicos y su estado
	def handle_call(:viewNodes, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Se devuelve la lista que contiene los nodos base
		{:reply, listaNodosBase, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end

	#Muestra los nodos principales y si están sincronizados o no
	def handle_call(:viewNodesM, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Se devuelve la lista que contiene los nodos maestros
		{:reply, listaNodosMaestros, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end

	#Muestra los ficheros con los nodos que lo tienen disponible
	def handle_call(:viewFiles, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Se devuelve la lista que contiene los ficheros
		{:reply, listaFicheros, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end

	#Muestra los nodos que tienen disponible el fichero 
	def handle_call({:viewFile, fileId}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Se seleccionan los nodos que tienen ese fichero
		nodesList = nodesByFile(fileId, listaFicheros)
		unless Enum.empty?(nodesList) do
			#Se escoje uno al azar
			node = Enum.random(nodesList)
			#Se busca su ip
			ipOfNode = ipByNode(node, listaNodosBase)
			#Devolvemos la ip del nodo
			{:reply, ipOfNode, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
		#Si no se tiene ningún nodo asociado al fichero o no existe el fichero se devuelve :not_found
		{:reply, :not_found, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

 	#Devuelve verdadero si el nodo está conectado
 	def handle_call({:nodeIsUp, node}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
 		{:reply, nodeIsUpFunction(node, listaNodosBase), [listaNodosMaestros,listaNodosBase,listaFicheros]}
 	end

	#Añade un nodo base
	def handle_cast({:addNode, node, ip}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el nodo se añade
		unless exists(node,listaNodosBase) do
			updated_listNodes = listaNodosBase ++ [{node,:DOWN, ip}]
			IO.puts("Añadido nodo base con id '#{node}' e ip '#{ip}'.")
			{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
		else
			IO.puts("No se ha podido añadir, '#{node}' ya existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	#Añade un nodo base
	def handle_cast({:addNodeM, nodeM, ip}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el nodo se añade
		unless exists(nodeM,listaNodosMaestros) do
			updated_listNodes = listaNodosMaestros ++ [{nodeM, :UNSYNC, ip}]
			#Se sincroniza el nodo que se acaba de añadir
			#nodeMSync(nodeM,[])
			IO.puts("Añadido nodo maestro con id '#{nodeM}' e ip '#{ip}'.")
			{:noreply, [updated_listNodes,listaNodosBase,listaFicheros]}
		else
			IO.puts("No se ha podido añadir, '#{nodeM}' ya existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	#Añade un fichero
	def handle_cast({:addFile, fileId, file}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el fichero lo añade
		unless exists(file,listaFicheros) do
			#Se aplica el hash al fichero
			hash = ""
			#Se añade
			updated_list = listaFicheros ++ [{fileId,hash,file,[]}]
			IO.puts("Añadido fichero '#{file}'")
			{:noreply, [listaNodosMaestros,listaNodosBase,updated_list]}
		else
			IO.puts("No se ha podido añadir, '#{file}' ya existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	 #Añade nodos a los ficheros
 	def handle_cast({:addNodeToFile, file, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
 		if exists(node, listaNodosBase) do
 			nodes = nodesByFile(file, listaFicheros)
 			unless inList?(node, nodes) do
				updated_listFiles = addNodeToFileFunction(file, node, listaFicheros)
				{:noreply, [listaNodosMaestros,listaNodosBase,updated_listFiles]}
			else
				{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
			end
		else 
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	#Elimina un nodo maestro 
	def handle_cast({:removeNodeM, nodeM}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodesM = delete(nodeM,listaNodosMaestros)
		if updated_listNodesM == listaNodosMaestros do
			IO.puts("No se ha podido eliminar, '#{nodeM}' no existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
			IO.puts("Eliminado nodo maestro '#{nodeM}'")
			{:noreply, [updated_listNodesM,listaNodosBase,listaFicheros]}
		end		
	end

	#Elimina un nodo base 
	def handle_cast({:removeNode, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodes = delete(node,listaNodosBase)
		if updated_listNodes == listaNodosBase do
			IO.puts("No se ha podido eliminar, '#{node}' no existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
			IO.puts("Eliminado nodo base '#{node}'")
			{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
		end		
	end

	#Elimina un fichero
	def handle_cast({:removeFile, file}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listFiles = delete(file,listaFicheros)
		if updated_listFiles == listaFicheros do
			IO.puts("No se ha podido eliminar, '#{file}' no existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
			IO.puts("Eliminado fichero '#{file}'")
			{:noreply, [listaNodosMaestros,listaNodosBase,updated_listFiles]}
		end		
	end

	#Elimina un nodo de un fichero
	def handle_cast({:removeNodeOfFile, file, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listFiles = removeNodeToFilesFunction(file, node, listaFicheros)
		if updated_listFiles == listaFicheros do
			IO.puts("No se ha podido eliminar, '#{node}' no existe")
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
			IO.puts("Eliminado nodo base '#{node}'")
			{:noreply, [listaNodosMaestros,listaNodosBase,updated_listFiles]}
		end
	end

	#Sincroniza un nodo maestro con este
 	def handle_cast({:nodeMSync, _, syncList}, _) do
 		#No tenemos manera de comunicar nodos intermedios por tcp
 		#Se actualizaria en campo de sincronización con la fecha y hora en que se haga
 		{:noreply, syncList}
 	end

	#Establece el estado de UP a un nodo base
	def handle_cast({:nodeUp, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodes = nodeStateFunction(node, :UP, listaNodosBase)
		if updated_listNodes == listaNodosBase do
			IO.puts("El nodo '#{node}' no existe o ya está levantado")
		else
			IO.puts("El nodo '#{node}' se ha levantado")
		end
		{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
	end

 	#Establece el estado de DOWN a un nodo base
	def handle_cast({:nodeDown, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodes = nodeStateFunction(node, :DOWN, listaNodosBase)
		if updated_listNodes == listaNodosBase do
			IO.puts("El nodo '#{node}' no existe o ya no está levantado")
		else
			IO.puts("El nodo '#{node}' se ha tirado")
		end
		{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
	end

	def handle_call({:idOfIp, ip}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		nodeId = idOfIp(ip,listaNodosBase)
		{:reply, nodeId, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end

	############################## FUNCIONES AUXILIARES ###########################

	def idOfIp(ip,[{id,_,ip}|_]), do: id

	def idOfIp(ip,[{_,_,_}|tail]), do: idOfIp(ip,tail)

	def idOfIp(_,[]), do: ""

	######################################################
	def nodeIsUpFunction(node, [{nodeId,state,_}|_])
		when node == nodeId and state == :UP do true
	end

	def nodeIsUpFunction(node, [{nodeId,_,_}|tail])
		when node != nodeId do nodeIsUpFunction(node, tail)
	end

	def nodeIsUpFunction(node, [{nodeId,state,_}|_])
		when node == nodeId and state != :UP do false
	end

	def nodeIsUpFunction(_, _), do: false

	####################################################

	def ipByNode(nodeId, [{nodeId,_, ip}|_]), do: ip

	def ipByNode(node, [_|tail]), do: ipByNode(node,tail)

	def ipByNode(_) do
		"ERROR"
	end

	####################################################

	def nodesByFile(file, [{fileId, _, _,listNodes}|_])
		when file == fileId do listNodes
	end

	def nodesByFile(file, [{fileId, _, _,}|tail])
		when file != fileId do nodesByFile(file, tail)
	end

	def nodesByFile(_, _), do: []

 	####################################################

 	# Para sabes si existe un nodo

 	def exists(id_want, [{id_want, _, _}|_]), do: true

 	def exists(id_want, [{_, _, _}|tail]), do: exists(id_want, tail)

 	# Para sabes si existe un fichero

 	def exists(id_want, [{id_want, _, _, _}|_]), do: true

 	def exists(id_want, [{_, _, _, _}|tail]), do: exists(id_want, tail)

 	def exists(_,_), do: false

	####################################################

	def delete(id_want,list), do: delete(id_want,list,[])

	def delete(_,[],aux), do: aux

	# Para eliminar un nodo

	def delete(id_want,[{id_want,_,_}|tail],aux), do: aux ++ tail

	def delete(id_want,[{id_list,state,ip}|tail],aux), do: delete(id_want, tail, aux++[{id_list,state,ip}])

	# Para eliminar un fichero

	def delete(id_want,[{id_want, _, _, _}|tail],aux), do: aux ++ tail

	def delete(id_want,[{id_list, hash, file, nodes}|tail],aux), do: delete(id_want, tail, aux++[{id_list, hash, file, nodes}])

	############################################################

	def nodeStateFunction(nodeId, state, list) do
		nodeStateFunction(nodeId, state, list, [])
	end

	def nodeStateFunction(nodeId, state, [{nodeId, _, ip}|tail], aux) do
		aux ++ [{nodeId, state, ip}|tail]
	end

	def nodeStateFunction(node, status, [{nodeID, state, id}|tail], aux) do
		nodeStateFunction(node, status, tail, aux ++ [{nodeID, state, id}])
	end

	def nodeStateFunction(_, _, _, aux) do
		aux
	end

################################################################
	def addNodeToFileFunction(fileId, node, listFilesNodes) do
		addNodeToFileFunction(fileId, node, listFilesNodes, [])
	end

	def addNodeToFileFunction(fileId, node, [{fileId, hash, file, listNodes}|tail], listAux) do
		listAux ++ [{fileId, hash, file, listNodes++[node]}|tail]
	end

	def addNodeToFileFunction(fileId, node, [{other_fileId, hash, file, listNodes}|tail], listAux) do
		addNodeToFileFunction(fileId, node, tail, listAux ++ [{other_fileId, hash, file, listNodes}])
	end

	def addNodeToFileFunction(_, _, [], listAux) do
		listAux
	end

###############################################################

	def inList?(node, [head|_])
		when node == head do true		
	end

	def inList?(node, [head|tail])
		when node != head do inList?(node,tail)
	end

	def inList?(_, _), do: false

	##################################################################

	def removeNodeToFilesFunction(file, node, listFiles) do
		removeNodeToFilesFunction(file, node, listFiles, [], [])
	end

	def removeNodeToFilesFunction(fileID, node, [{fileID, hash, file, [node|tail]}|_], listAuxFileList, listAuxNodesList) do
		listAuxFileList ++ [{fileID,hash, file,listAuxNodesList ++ tail}]
	end

	def removeNodeToFilesFunction(fileID, node, [{fileID, hash, file, [other_node|tail]}|tail2], listAuxFileList, listAuxNodesList) do
		removeNodeToFilesFunction(fileID, node, [{fileID, hash, file, tail}|tail2], listAuxFileList, listAuxNodesList ++ [other_node])
	end

	def removeNodeToFilesFunction(fileID, listNodes, [{other_fileID, hash, file, listNodesFiles}|tail], listAuxFileList, _) do
		removeNodeToFilesFunction(fileID, listNodes, tail,listAuxFileList ++ [{other_fileID, hash, file,listNodesFiles}], [])
	end

	def removeNodeToFilesFunction(_, _, [], listAuxFileList, _) do
		listAuxFileList
	end
	##############################################################################


	def init([listaNodosMaestros,listaNodosBase,listaFicheros]) do
		{:ok, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end
end

##########################


# Esquema de estructura actual
# [
#   [
#		{"NodeM1", :UNSYNC, "11.10.10.10"}, 
#		{"NodeM2", :UNSYNC, "12.10.10.10"}],
#   [
#     	{"Node1", :DOWN, "10.10.10.10"},
#     	{"Node2", :DOWN, "20.10.10.10"},
#     	{"Node3", :DOWN, "30.10.10.10"},
#     	{"Node4", :DOWN, "40.10.10.10"},
#     	{"Node5", :DOWN, "50.10.10.10"},
#     	{"Node6", :DOWN, "60.10.10.10"}
#   ],
#   [
#		{"File1", ["Node1"]},
#		{"File2", ["Node2"]}, 
#		{"File3", ["Node1", "Node2"]}
#	]
# ]
# ) 