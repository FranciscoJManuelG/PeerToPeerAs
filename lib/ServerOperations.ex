defmodule ServerOperations do
	use GenServer
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
		{:reply, Kernel.inspect(list), list}
	end

	#Muestra los nodos que tienen disponible el fichero 
	def handle_call({:viewFile, fileId}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Se seleccionan los nodos que tienen ese fichero
		nodesList = Utils.nodesByFile(fileId, listaFicheros)
		unless Enum.empty?(nodesList) do
			#Se escoje uno al azar
			node = Enum.random(nodesList)
			#Se busca su ip
			ipOfNode = Utils.ipByNode(node, listaNodosBase)
			#Devolvemos la ip del nodo
			{:reply, ipOfNode, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
		#Si no se tiene ningún nodo asociado al fichero o no existe el fichero se devuelve :not_found
		{:reply, "File not found", [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

 	#Devuelve verdadero si el nodo está conectado
 	def handle_call({:nodeIsUp, node}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
 		{:reply, Utils.nodeIsUpFunction(node, listaNodosBase), [listaNodosMaestros,listaNodosBase,listaFicheros]}
 	end

	#Añade un nodo base
	def handle_cast({:addNode, node, ip}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el nodo se añade
		unless Utils.exists(node,listaNodosBase) do
			updated_listNodes = [{node,:UP, ip}|listaNodosBase]
			{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
		else
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	#Añade un nodo base
	def handle_cast({:addNodeM, nodeM, ip}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el nodo se añade
		unless Utils.exists(nodeM,listaNodosMaestros) do
			updated_listNodes = [{nodeM, :UNSYNC, ip}|listaNodosMaestros]
			{:noreply, [updated_listNodes,listaNodosBase,listaFicheros]}
		else
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	#Añade un fichero
	def handle_cast({:addFile, fileId, hash}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		#Si no existe el fichero lo añade
		unless Utils.exists(fileId,listaFicheros) do
			#Se aplica el hash al fichero
			#hash = :crypto.hash(:sha256, file)
			#Se añade
			updated_list = [{fileId,hash,[]}|listaFicheros]
			{:noreply, [listaNodosMaestros,listaNodosBase,updated_list]}
		else
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		end
	end

	 #Añade nodos a los ficheros
 	def handle_cast({:addNodeToFile, file, hash, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
 		if Utils.exists(node, listaNodosBase) do
 			nodes = Utils.nodesByFile(file, listaFicheros)
 			unless Utils.inList?(node, nodes) do
				updated_listFiles = Utils.addNodeToFileFunction(file, hash, node, listaFicheros)
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
		updated_listNodesM = Utils.delete(nodeM,listaNodosMaestros)
		if updated_listNodesM == listaNodosMaestros do
			{:noreply, [listaNodosMaestros,listaNodosBase,listaFicheros]}
		else
			{:noreply, [updated_listNodesM,listaNodosBase,listaFicheros]}
		end		
	end

	#Establece el estado de UP a un nodo base
	def handle_cast({:nodeUp, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodes = Utils.nodeStateFunction(node, :UP, listaNodosBase)
		{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
	end

 	#Establece el estado de DOWN a un nodo base
	def handle_cast({:nodeDown, node}, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		updated_listNodes = Utils.nodeStateFunction(node, :DOWN, listaNodosBase)
		{:noreply, [listaNodosMaestros,updated_listNodes,listaFicheros]}
	end

	def handle_call({:idOfIp, ip}, _from, [listaNodosMaestros,listaNodosBase,listaFicheros]) do
		nodeId = Utils.idOfIp(ip,listaNodosBase)
		{:reply, nodeId, [listaNodosMaestros,listaNodosBase,listaFicheros]}
	end

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