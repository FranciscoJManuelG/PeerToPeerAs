defmodule ServerWIP do
	use GenServer

	#Client
  	def start_link() do
    	GenServer.start_link(__MODULE__, [[],[],[]])
  	end

  	def addNode(pid, node) do
  		GenServer.cast(pid, {:addNode, node})
  	end

  	def addNodeM(pid, nodeM) do
  		GenServer.cast(pid, {:addNodeM, nodeM})
  	end

  	def addFile(pid, file) do
  		GenServer.cast(pid, {:addFile, file})
  	end

  	def viewAll(pid) do
		GenServer.call(pid, :viewAll)
	end

  	def viewNodes(pid) do
		GenServer.call(pid, :viewNodes)
	end

	def viewNodesM(pid) do
		GenServer.call(pid, :viewNodesM)
	end

	def viewNodesFiles(pid) do
		GenServer.call(pid, :viewNodesFiles)
	end

	def removeNode(pid, node) do
		GenServer.cast(pid, {:removeNode, node})
	end

#
	def nodeMUp(pid, node) do
  		GenServer.cast(pid, {:nodeMUp, node})
  	end

	def nodeMDown(pid, node) do
		GenServer.cast(pid, {:nodeMDown, node})
	end

	def add(pid, item) do
		GenServer.cast(pid, {:addItem, item})
	end

	def view(pid) do
		GenServer.call(pid, :view)
	end

	def remove(pid, item) do
		GenServer.cast(pid, {:remove, item})
	end

	def stop(pid) do
		GenServer.stop(pid)
	end

	#Server	
	def terminate() do
		IO.puts("** STOPING SERVER **")
		:ok
	end

	def handle_call(:viewAll, _from, list) do
		{:reply, list, list}
	end

	def handle_call(:viewNodes, _from, [other,nodeList,other2]) do
		{:reply, nodeList, [other,nodeList,other2]}
	end

	def handle_call(:viewNodesM, _from, [listNodeM,other,other2]) do
		{:reply, listNodeM, [listNodeM,other,other2]}
	end

	def handle_call(:viewNodesFiles, _from, [other,other2,nodesFiles]) do
		{:reply, nodesFiles, [other,other2,nodesFiles]}
	end

	def handle_cast({:addNode, node}, [other,listNodes,other2]) do 
		updated_listNodes = listNodes ++ [{node,:DOWN}]
		{:noreply, [other,updated_listNodes,other2]}
	end

	def handle_cast({:addNodeM, nodeM}, [listNodesM,other,other2]) do 
		updated_list = listNodesM ++ [{nodeM,:UNSYNC}]
		{:noreply, [updated_list,other,other2]}
	end

	def handle_cast({:addFile, file}, [other,other2,listFilesNodes]) do
		updated_list = listFilesNodes ++ [file,[]]
		{:noreply, [other,other2,updated_list]}
	end

	def aux_remove(node, [{nodeID, state}|others], list_aux)
		when (node == nodeID) do [list_aux ++ others]		
	end

	def aux_remove(node, [{nodeID, info}|others], list_aux)
		when (node != nodeID) do aux_remove(node, others, list_aux ++ [{nodeID, info}])		
	end

	def handle_cast({:remove, node}, [list1, list2, list3]) do
		updated_listNodes = aux_remove(node, list2, [])
		{:noreply, [list1, updated_listNodes, list3]}
	end

	#No funciona
	#def handle_cast({:remove, node}, [other, [{nodeID, state}|others1], [{nodeID2, files}|others2]]) do
	#	updated_listNodes = Enum.reject([{nodeID, state}|others1], fn({node_aux, _}) -> node_aux == nodeID end)
	#	updated_listNodesFiles = Enum.reject([{nodeID2, files}|others2], fn({node_aux, _}) -> node_aux == nodeID2 end)
	#	{:noreply, [other, updated_listNodes, updated_listNodesFiles]}
	#end

#	def handle_cast({:nodeUp, node}, [other,{}]) do 
#		updated_list = listNodesM ++ [nodeM]
#		{:noreply, [other,updated_list]}
#	end

	#def handle_cast({:removeNode, node}, [other,nodeList]) do
	#	updated_list = Enum.reject(nodeList, fn(i) -> i == nodeId end)
	#	{:noreply, [other,updated_list]}
	#end

	def init([nodesMaster, nodesList, nodesFiles]) do
		{:ok, [nodesMaster, nodesList, nodesFiles]}
	end
end

#{_,pid}=ServerWIP.start_link()
#ServerWIP.addNode(pid,Node1)
#ServerWIP.addNode(pid,Node2)
#ServerWIP.addNode(pid,Node3)
#ServerWIP.addNode(pid,Node4)
#ServerWIP.addNode(pid,Node5)
#ServerWIP.addNode(pid,Node6)
#ServerWIP.addNodeM(pid,NodeM1)
#ServerWIP.addNodeM(pid,NodeM2)
#ServerWIP.viewNodes(pid)
#ServerWIP.viewNodesM(pid)
#ServerWIP.viewNodesFiles(pid)
#ServerWIP.viewAll(pid)