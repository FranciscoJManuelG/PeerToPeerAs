defmodule ServerWIP do
	use GenServer

	#Client
	def start do
		start_link()
	end

  	def addNode(node, ip) do
  		IO.puts("Añadiendo nodo base con id '#{String.trim(node)}' e ip '#{String.trim(ip)}'.")
  		GenServer.cast(:server, {:addNode, node, ip})
  	end

  	def addNodeM(nodeM, ip) do
  		IO.puts("Añadiendo nodo maestro con id '#{String.trim(nodeM)}' e ip '#{String.trim(ip)}'.")
  		GenServer.cast(:server, {:addNodeM, nodeM, ip})
  	end

  	def addFile(file) do
  		IO.puts("Añadiendo fichero con id '#{String.trim(file)}'")
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
		IO.puts("Eliminando nodo base '#{String.trim(node)}'")
		GenServer.cast(:server, {:removeNode, node})
	end

	def removeNodeM(nodeM) do
		IO.puts("Eliminando nodo maestro '#{String.trim(nodeM)}'")
		GenServer.cast(:server, {:removeNodeM, nodeM})
	end

	def removeFile(file) do
		IO.puts("Eliminando fichero '#{String.trim(file)}'")
		GenServer.cast(:server, {:removeFile, file})
	end

	def nodeUp(node) do
		IO.puts("Estableciendo nodo base como activo '#{String.trim(node)}'")
  		GenServer.cast(:server, {:nodeUp, node})
  	end

  	def nodeDown(node) do
  		IO.puts("Estableciendo nodo base como apagado '#{String.trim(node)}'")
  		GenServer.cast(:server, {:nodeDown, node})
  	end

  	def nodeMSync(nodeM) do
  		IO.puts("Estableciendo nodo master como sincronizado '#{String.trim(nodeM)}'")
  		GenServer.cast(:server, {:nodeMSync, nodeM})
  	end

  	def nodeMUnsync(nodeM) do
  		IO.puts("Estableciendo nodo master como desincronizado '#{String.trim(nodeM)}'")
  		GenServer.cast(:server, {:nodeMUnsync, nodeM})
  	end

	def addNodesToFiles(file, nodes) do
		IO.puts("Añadiendo '#{nodes}' al fichero '#{String.trim(file)}'")
		GenServer.cast(:server, {:addNodesToFiles, file, nodes})
	end

	def stop() do
		IO.puts("Parando servidor")
		GenServer.stop()
	end

	#Server

	#Arranca el servidor
	defp start_link() do
    	{:ok, pid} = GenServer.start_link(__MODULE__, [[],[],[],[],[]])
    	Process.register(pid,:server)
    	:ok
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
		updated_listNodes = list2 ++ [{node,:DOWN}]
		updated_listNodesIps = list4 ++ [{node, ip}]
		{:noreply, [list1,updated_listNodes,list3,updated_listNodesIps,list5]}
	end

	#Añade un nodo principal
	def handle_cast({:addNodeM, nodeM, ip}, [list1,list2,list3,list4, list5]) do 
		updated_list = list1 ++ [{nodeM,:UNSYNC}]
		updated_listNodesMIps = list5 ++ [{nodeM, ip}]
		{:noreply, [updated_list,list2,list3, list4, updated_listNodesMIps]}
	end

	#Añade un fichero
	def handle_cast({:addFile, file}, [list1,list2,list3,list4,list5]) do
		updated_list = list3 ++ [{file,[]}]
		{:noreply, [list1,list2,updated_list,list4,list5]}
	end

	#Elimina un nodo principal ***NO ELIMINA EL NODOIP***
	def handle_cast({:removeNodeM, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :UNSYNC, x) end)
		updated_listNodesM = List.delete(updated_listNodesM, {nodeM, :UNSYNC})
		#updated_listNodesMIps = List.delete(list5, {nodeM, ip})
		{:noreply, [updated_listNodesM, list2, list3,list4, list5]}
	end

	#Elimina un nodo base ***NO ELIMINA EL NODOIP***
	def handle_cast({:removeNode, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :DOWN, x) end)
		updated_listNodes = List.delete(updated_listNodes, {node, :DOWN})
		#updated_listNodesIps = List.delete(list4, {node, ip})
		{:noreply, [list1, updated_listNodes, list3, list4, list5]}
	end

	#Elimina un fichero ***NO FUNCIONA***
	def handle_cast({:removeFile, file}, [list1, list2, list3, list4, list5]) do
		#updated_listFiles = Enum.map(list3, fn x -> fileEmptyFunction(file, x) end)
		updated_listFiles = List.delete(list3, {node, []})
		{:noreply, [list1, list2, updated_listFiles, list4, list5]}
	end

	#Elimina un nodo de un fichero ***NO FUNCIONA***
	def handle_cast({:removeNodeFile, file, node}, [list1, list2, list3, list4, list5]) do
		#updated_listFiles = Enum.map(list3, fn x -> fileEmptyFunction(file, node, x) end)
		updated_listFiles = List.delete(list3, {node, })
		{:noreply, [list1, list2, updated_listFiles, list4, list5]}
	end

	#Sincroniza un nodo principal con este
	def handle_cast({:nodeMSync, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :SYNC, x) end)
		{:noreply, [updated_listNodesM,list2,list3, list4, list5]}
	end

	#Establece el estado de UNSYNC a un nodo principal
	def handle_cast({:nodeMUnsync, nodeM}, [list1, list2, list3, list4, list5]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :UNSYNC, x) end)
		{:noreply, [updated_listNodesM,list2,list3, list4, list5]}
	end

	#Establece el estado de UP a un nodo base
	def handle_cast({:nodeUp, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :UP, x) end)
		{:noreply, [list1,updated_listNodes,list3, list4, list5]}
	end

	#Establece el estado de DOWN a un nodo base
	def handle_cast({:nodeDown, node}, [list1, list2, list3, list4, list5]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :DOWN, x) end)
		{:noreply, [list1,updated_listNodes,list3, list4, list5]}
	end

	#Añade nodos a los ficheros
	def handle_cast({:addNodesToFiles, file, nodes}, [list1, list2, list3, list4, list5]) do
		updated_listFiles = Enum.map(list3, fn x -> addNodesToFilesFunction(file, nodes, x) end)
		{:noreply, [list1,list2,updated_listFiles, list4, list5]}
	end

	############################## FUNCIONES AUXILIARES ###########################

	def nodeStateFunction(node, state, {nodeID, _})
		when node == nodeID do {node, state}
	end

	def nodeStateFunction(node, _, {nodeID, status})
		when node != nodeID do {nodeID, status}
	end

	def addNodesToFilesFunction(file, nodes, fileID)
		when file == fileID do {fileID, nodes}
	end

	def addNodesToFilesFunction(file, nodes, {fileID, nodesList})
		when file == fileID do {fileID, nodesList++nodes}
	end

	def addNodesToFilesFunction(file, _, {fileID, nodesList})
		when file != fileID do {fileID, nodesList}
	end

	def addNodesToFilesFunction(file, _, fileID)
		when file != fileID do {fileID, []}
	end

	##############################################################################

	def init([nodesMaster, nodesList, nodesFiles, nodesIps, nodesMIps]) do
		{:ok, [nodesMaster, nodesList, nodesFiles, nodesIps, nodesMIps]}
	end
end

##########################
# Para probar:
# ServerWIP.start()
# ServerWIP.addNode("Node1","10.10.10.10")
# ServerWIP.addNode("Node2","20.10.10.10")
# ServerWIP.addNode("Node3","30.10.10.10")
# ServerWIP.addNode("Node4","40.10.10.10")
# ServerWIP.addNode("Node5","50.10.10.10")
# ServerWIP.addNode("Node6","60.10.10.10")
# ServerWIP.addNodeM("NodeM1","11.10.10.10")
# ServerWIP.addNodeM("NodeM2","12.10.10.10")
# ServerWIP.addFile("File1")
# ServerWIP.addFile("File2")
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
# ServerWIP.viewNodes()
# ServerWIP.nodeDown("Node5")
# ServerWIP.viewNodes()
# ServerWIP.removeNode("Node4")
# ServerWIP.viewNodes()
# ServerWIP.nodeUp("Node4")
# ServerWIP.nodeUp("Node5")
# ServerWIP.nodeMSync("NodeM1")
# ServerWIP.nodeMSync("NodeM2")
# ServerWIP.removeNodeM("NodeM1")
# ServerWIP.viewAll()
# ServerWIP.addNodesToFiles("File1",["Node3","Node4"])
# ServerWIP.viewAll()
# ServerWIP.viewNodes()
# ServerWIP.addFile("File1")
# ServerWIP.addFile("File2")
# ServerWIP.removeFile("File2")
# ServerWIP.viewFiles()
# ServerWIP.addNodesToFiles("File1",["Node1","Node2"])
# ServerWIP.viewFiles()
# ServerWIP.addNodesToFiles("File1",["Node3","Node4"])
# ServerWIP.viewFiles()
# ServerWIP.removeFile("File2")
# ServerWIP.viewFiles()
# ServerWIP.stop()
