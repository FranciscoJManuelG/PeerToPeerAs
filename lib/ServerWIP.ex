defmodule ServerWIP do
	use GenServer
	require Logger

	#Client
  	def addNode(node, ip) do
  		IO.puts("Añadiendo nodo base con id '#{node}' e ip '#{ip}'.")
  		GenServer.cast(:server, {:addNode, node, ip})
  	end

  	def addNodeM(nodeM, ip) do
  		IO.puts("Añadiendo nodo maestro con id '#{nodeM}' e ip '#{ip}'.")
  		GenServer.cast(:server, {:addNodeM, nodeM, ip})
  	end

  	def addFile(file) do
  		IO.puts("Añadiendo fichero con id '#{file}'")
  		GenServer.cast(:server, {:addFile, file})
  	end

  	def viewAll() do
  		IO.puts("Mostrando la estructura completa del nodo")
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

	def viewNodesIp() do
		IO.puts("Mostrando la estructura de los nodo base con sus ips")
		GenServer.call(:server, :viewNodesIp)
	end

	def viewNodesMIp() do
		IO.puts("Mostrando la estructura de los nodo maestros con sus ips")
		GenServer.call(:server, :viewNodesMIp)
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

  	def nodeMSync(nodeM) do
  		IO.puts("Estableciendo nodo master como sincronizado '#{nodeM}'")
  		GenServer.cast(:server, {:nodeMSync, nodeM})
  	end

  	def nodeMUnsync(nodeM) do
  		IO.puts("Estableciendo nodo master como desincronizado '#{nodeM}'")
  		GenServer.cast(:server, {:nodeMUnsync, nodeM})
  	end

	def addNodesToFiles(file, nodes) do
		IO.puts("Añadiendo '#{nodes}' al fichero '#{file}'")
		GenServer.cast(:server, {:addNodesToFiles, file, nodes})
	end

	def removeNodesOfFile(file, nodes) do
		IO.puts("Eliminando '#{nodes}' del fichero '#{file}'")
		GenServer.cast(:server, {:removeNodesOfFile, file, nodes})
	end

	#Server

	#Arranca el servidor
	def start() do
    	{:ok, pid} = GenServer.start_link(__MODULE__, [[],[],[],[],[]])
    	Process.register(pid,:server)
    	:ok
  	end

    # handle the trapped exit call
    def stop() do
    	GenServer.stop(:server)
    end

  	#Muestra la estructura completa
	def handle_call(:viewAll, _from, list) do
		{:reply, list, list}
	end

	#Muestra los nodos básicos y su estado
	def handle_call(:viewNodes, _from, [list1,list2,list3,list4, list5]) do
		{:reply, list2, [list1,list2,list3,list4, list5]}
	end

	#Muestra los nodos principales y si están sincronizados o no
	def handle_call(:viewNodesM, _from, [list1,list2,list3,list4, list5]) do
		{:reply, list1, [list1,list2,list3,list4, list5]}
	end

	#Muestra los ficheros con los nodos que lo tienen disponible
	def handle_call(:viewFiles, _from, [list1,list2,list3,list4, list5]) do
		{:reply, list3, [list1,list2,list3,list4, list5]}
	end

	#Muestra las ips asociadas a los nodos base
	def handle_call(:viewNodesIp, _from, [list1,list2,list3,list4, list5]) do
		{:reply, list4, [list1,list2,list3,list4, list5]}
	end

	#Muestra las ips asociadas a los nodos master
	def handle_call(:viewNodesMIp, _from, [list1,list2,list3,list4, list5]) do
		{:reply, list5, [list1,list2,list3,list4, list5]}
	end

	#Añade un nodo base
	def handle_cast({:addNode, node, ip}, [list1,list2,list3,list4, list5]) do
		case canAdd(node,list2) do
			true -> 	updated_listNodes = list2 ++ [{node,:DOWN}]
						updated_listNodesIps = list4 ++ [{node, ip}]
						IO.puts("Añadido")
						{:noreply, [list1,updated_listNodes,list3,updated_listNodesIps,list5]}

			false ->	IO.puts("No se ha podido añadir, '#{node}' ya existe")
						{:noreply, [list1,list2,list3,list4,list5]}
		end
	end

	#Añade un nodo maestro
	def handle_cast({:addNodeM, nodeM, ip}, [list1,list2,list3,list4, list5]) do 
		case canAdd(nodeM,list1) do
			true -> 	updated_list = list1 ++ [{nodeM,:UNSYNC}]
						updated_listNodesMIps = list5 ++ [{nodeM, ip}]
						IO.puts("Añadido")
						{:noreply, [updated_list,list2,list3, list4, updated_listNodesMIps]}

			false -> 	IO.puts("No se ha podido añadir, '#{nodeM}' ya existe")
						{:noreply, [list1,list2,list3, list4, list5]}
		end
	end

	#Añade un fichero
	def handle_cast({:addFile, file}, [list1,list2,list3,list4,list5]) do
		case canAdd(file,list3) do
			true ->		updated_list = list3 ++ [{file,[]}]
						IO.puts("Añadido")
						{:noreply, [list1,list2,updated_list,list4,list5]}

			false -> 	IO.puts("No se ha podido añadir, '#{file}' ya existe")
						{:noreply, [list1,list2,list3,list4,list5]}
		end
	end

	#Elimina un nodo maestro 
	def handle_cast({:removeNodeM, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = deleteX(nodeM,list1)
		case updated_listNodesM == list1 do
			true -> 	IO.puts("No se ha podido eliminar, '#{nodeM}' no existe")
						{:noreply, [list1, list2, list3,list4, list5]}

			false ->	IO.puts("Eliminado nodo maestro '#{nodeM}'")
						updated_listNodesMIps = deleteX(nodeM,list5)
						{:noreply, [updated_listNodesM, list2, list3,list4, updated_listNodesMIps]}
		end		
	end

	#Elimina un nodo base
	def handle_cast({:removeNode, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = deleteX(node,list2)
		case updated_listNodes == list2 do
			true -> 	IO.puts("No se ha podido eliminar, '#{node}' no existe")
						{:noreply, [list1, list2, list3,list4, list5]}

			false ->	IO.puts("Eliminado nodo base '#{node}'")
						updated_listNodesIps = deleteX(node,list4)
						{:noreply, [list1, updated_listNodes, list3,updated_listNodesIps, list5]}
		end		
	end

	#Elimina un fichero
	def handle_cast({:removeFile, file}, [list1, list2, list3, list4, list5]) do
		updated_listFiles = deleteX(file,list3)
		case updated_listFiles == list3 do
			true -> 	IO.puts("No se ha podido eliminar, '#{file}' no existe")
						{:noreply, [list1, list2, list3,list4, list5]}

			false ->	IO.puts("Eliminado fichero '#{file}'")
						{:noreply, [list1, list2, updated_listFiles,list4, list5]}
		end
	end

	#Sincroniza un nodo principal con este
	def handle_cast({:nodeMSync, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :SYNC, x) end)
		case updated_listNodesM == list1 do
			true -> IO.puts("El nodo '#{nodeM}' no existe o ya está sincronizado")
			false -> IO.puts("El nodo '#{nodeM}' se ha sincronizado")
		end
		{:noreply, [updated_listNodesM,list2,list3, list4, list5]}
	end

	#Establece el estado de UNSYNC a un nodo principal
	def handle_cast({:nodeMUnsync, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :UNSYNC, x) end)
		case updated_listNodesM == list1 do
			true -> IO.puts("El nodo '#{nodeM}' no existe o ya está desincronizado")
			false -> IO.puts("El nodo '#{nodeM}' se ha desincronizado")
		end
		{:noreply, [updated_listNodesM,list2,list3, list4, list5]}
	end

	#Establece el estado de UP a un nodo base
	def handle_cast({:nodeUp, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :UP, x) end)
		case updated_listNodes == list2 do
			true -> IO.puts("El nodo '#{node}' no existe o ya está levantado")
			false -> IO.puts("El nodo '#{node}' se ha levantado")
		end
		{:noreply, [list1,updated_listNodes,list3, list4, list5]}
	end

	#Establece el estado de DOWN a un nodo base
	def handle_cast({:nodeDown, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :DOWN, x) end)
		case updated_listNodes == list2 do
			true -> IO.puts("El nodo '#{node}' no existe o ya está tirado")
			false -> IO.puts("El nodo '#{node}' se ha tirado")
		end
		{:noreply, [list1,updated_listNodes,list3, list4, list5]}
	end

	#Añade nodos a los ficheros
	#Comprobar que los nodos existen (Si el primer nodo no existe los otros fallan)
	#Si se pasa un file que no existe se borra la lista de files
	def handle_cast({:addNodesToFiles, file, nodes}, [list1, list2, list3, list4, list5]) do
		updated_listFiles = addNodesToFilesFunction(file, nodes, list3, list2)
		{:noreply, [list1,list2,updated_listFiles, list4, list5]}
	end

	#Elimina un nodo de un fichero ** NO FUNCIONA ** 
	def handle_cast({:removeNodesOfFile, file, nodes}, [list1, list2, list3, list4, list5]) do
		updated_listFiles = removeNodesToFilesFunction(file, nodes, list3)
		{:noreply, [list1, list2, updated_listFiles, list4, list5]}
	end

	#Sincroniza dos nodos maestros
	#FALTA

	############################## FUNCIONES AUXILIARES ###########################

	def canAdd(x, [{xID, _}|_])
		when x == xID do false
	end

	def canAdd(x, [{xID, _}|tail])
		when x != xID do canAdd(x,tail)
	end

	def canAdd(_, []) do
		true
	end

	####################################################

	def deleteX(x,list) do
		deleteX(x,list,[])
	end

	def deleteX(_,[],aux) do
		aux
	end

	def deleteX(x,[{xID,_}|tail],aux)
		when x == xID do aux ++ tail
	end

	def deleteX(x,[{xID,otherInfo}|tail],aux)
		when x != xID do deleteX(x, tail, aux++[{xID,otherInfo}])
	end	

	#############################################################

	def nodeStateFunction(node, state, {nodeID, _})
		when node == nodeID do {node, state}
	end

	def nodeStateFunction(node, _, {nodeID, status})
		when node != nodeID do {nodeID, status}
	end
#################################################################

	def isNotNodeInFileFunction(node, [head|_])
		when node == head do false		
	end

	def isNotNodeInFileFunction(node, [head|tail])
		when node != head do isNotNodeInFileFunction(node,tail)
	end

	def isNotNodeInFileFunction(_, _) do
		true
	end

	##################################################################

	def addNodesToFilesFunction(file, listNodes, listFiles, list2) do
		addNodesToFilesFunction(file, listNodes, listFiles, list2, [])
	end

	def addNodesToFilesFunction(file, [node|nodesTail], [{fileID,nodeList}|tail],list2, listAux) do
		case file == fileID do
			true ->		case isNotNodeInFileFunction(node, nodeList) do
							true ->		case canAdd(node,list2) do
											false -> 	IO.puts("Insertado el nodo '#{node}' al fichero '#{file}'")
														addNodesToFilesFunction(file,nodesTail,[{fileID,nodeList ++ [node]}|tail], listAux)

											true ->		IO.puts("El nodo '#{node}' no está registrado")
														addNodesToFilesFunction(file,nodesTail,[{fileID,nodeList}|tail], listAux)
										end

							false ->	IO.puts("El nodo '#{node}' ya está asociado al fichero '#{file}'")
										addNodesToFilesFunction(file,nodesTail,[{fileID,nodeList}|tail], listAux)
						end
			false ->	addNodesToFilesFunction(file,[node|nodesTail],tail,listAux ++ [{fileID,nodeList}])
		end
	end

	def addNodesToFilesFunction(file, _, [],_, _) do
		IO.puts("El fichero '#{file}' no está registrado")
	end

	def addNodesToFilesFunction(_, _, listFiles,_ ,listAux) do
		listAux ++ listFiles
	end

	##############################################################################
	def removeNodesToFileFunction([], listNodesFiles, _) do
		listNodesFiles
	end

	def removeNodesToFileFunction([node|nodesTail], [nodeFile|nodesFileTail], listAux)
		when node == nodeFile do
			IO.puts("Se ha eliminado el nodo '#{node}' del fichero '#{nodeFile}'")
			removeNodesToFileFunction([nodesTail], [nodesFileTail], listAux)
	end

	def removeNodesToFileFunction([node|nodesTail], [nodeFile|nodesFileTail], listAux)
		when node != nodeFile do
			removeNodesToFileFunction([node|nodesTail], [nodesFileTail], listAux++[nodeFile])
	end

	def removeNodesToFileFunction([_|nodesTail], [], listAux) do 
		removeNodesToFileFunction([nodesTail], listAux, [])
	end

	##############################################################################
	def removeNodesToFilesFunction(file, listNodes, listFiles) do
		removeNodesToFilesFunction(file, listNodes, listFiles, [])
	end

	def removeNodesToFilesFunction(file, listNodes, [{fileID,listNodesFiles}|tail], listAux) do
		case file == fileID do
			true ->		update_nodeList = removeNodesToFileFunction(listNodes, listNodesFiles, [])
						listAux ++ [{fileID,update_nodeList}]
			false ->	removeNodesToFilesFunction(file,listNodes,tail,listAux ++ [{fileID,listNodesFiles}])
		end
	end

	def removeNodesToFilesFunction(file, _, [], _) do
		IO.puts("El fichero '#{file}' no está registrado")
	end

	def removeNodesToFilesFunction(_, _, listFiles, listAux) do
		listAux ++ listFiles
	end
	##############################################################################


	def init([nodesMaster, nodesList, nodesFiles, nodesIps, nodesMIps]) do
		{:ok, [nodesMaster, nodesList, nodesFiles, nodesIps, nodesMIps]}
	end
end

##########################
# ServerWIP.start()
# ServerWIP.addNode("Node1","10.10.10.10")
# ServerWIP.addNode("Node2","20.10.10.10")
# ServerWIP.addNode("Node3","30.10.10.10")
# ServerWIP.addNode("Node4","40.10.10.10")
# ServerWIP.addNode("Node5","50.10.10.10")
# ServerWIP.addNode("Node6","60.10.10.10")
# ServerWIP.addNode("Node6","60.10.10.10")
# ServerWIP.addNodeM("NodeM1","11.10.10.10")
# ServerWIP.addNodeM("NodeM2","12.10.10.10")
# ServerWIP.addNodeM("NodeM2","12.10.10.10")
# ServerWIP.addFile("File1")
# ServerWIP.addFile("File2")
# ServerWIP.addFile("File3")
# ServerWIP.addFile("File3")
# ServerWIP.viewNodes()
# ServerWIP.viewNodesM()
# ServerWIP.viewFiles()
# ServerWIP.viewNodesIp()
# ServerWIP.viewNodesMIp()
# ServerWIP.viewAll()
# ServerWIP.removeNode("Node1")
# ServerWIP.removeNode("Node2")
# ServerWIP.viewAll()
# ServerWIP.nodeUp("Node4")
# ServerWIP.nodeUp("Node5")
# ServerWIP.nodeDown("Node5")
# ServerWIP.removeNode("Node4")
# ServerWIP.nodeUp("Node4")
# ServerWIP.nodeUp("Node5")
# ServerWIP.nodeMSync("NodeM1")
# ServerWIP.nodeMSync("NodeM2")
# ServerWIP.removeNodeM("NodeM1")
# ServerWIP.viewAll()
# ServerWIP.addNodesToFiles("File1",["Node3","Node4"])
# ServerWIP.addFile("File1")
# ServerWIP.addFile("File2")
# ServerWIP.removeFile("File2")
# ServerWIP.addNodesToFiles("File1",["Node1","Node2"])
# ServerWIP.addNodesToFiles("File1",["Node3","Node4"])
# ServerWIP.removeFile("File2")
# ServerWIP.viewAll()
# ServerWIP.stop()