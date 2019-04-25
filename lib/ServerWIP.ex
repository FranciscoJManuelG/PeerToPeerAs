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

	def removeNode(pid, node) do
		GenServer.cast(pid, {:removeNode, node})
	end

	def removeNodeM(pid, nodeM) do
		GenServer.cast(pid, {:removeNodeM, nodeM})
	end

	def nodeUp(pid, node) do
  		GenServer.cast(pid, {:nodeUp, node})
  	end

  	def nodeDown(pid, node) do
  		GenServer.cast(pid, {:nodeDown, node})
  	end

  	def nodeMSync(pid, nodeM) do
  		GenServer.cast(pid, {:nodeMSync, node})
  	end

  	def nodeMUnsync(pid, nodeM) do
  		GenServer.cast(pid, {:nodeMUnsync, node})
  	end

	def viewNodesFiles(pid) do
		GenServer.call(pid, :viewNodesFiles)
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
		updated_list = listNodesM ++ [{nodeM,:SYNC}]
		{:noreply, [updated_list,other,other2]}
	end

	def handle_cast({:addFile, file}, [other,other2,listFilesNodes]) do
		updated_list = listFilesNodes ++ [file,[]]
		{:noreply, [other,other2,updated_list]}
	end

	def nodeStateFunction(node, state, {nodeID, status})
		when node == nodeID do {node, state}
	end

	def nodeStateFunction(node, state, {nodeID, status})
		when node != nodeID do {nodeID, status}
	end

	def handle_cast({:removeNodeM, nodeM}, [list1, list2, list3]) do
		updated_listNodesM = Enum.map(list1, fn x -> nodeStateFunction(nodeM, :UNSYNC, x) end)
		updated_listNodesM = List.delete(updated_listNodesM, {nodeM, :UNSYNC})
		{:noreply, [updated_listNodesM, list2, list3]}
	end

	def handle_cast({:removeNode, node}, [list1, list2, list3]) do
		updated_listNodes = Enum.map(list2, fn x -> nodeStateFunction(node, :DOWN, x) end)
		updated_listNodes = List.delete(updated_listNodes, {node, :DOWN})
		{:noreply, [list1, updated_listNodes, list3]}
	end

	def handle_cast({:nodeMSync, nodeM}, [list, list2, list3]) do
		updated_listNodesM = Enum.map(list, fn x -> nodeStateFunction(nodeM, :SYNC, x) end)
		{:noreply, [updated_listNodesM,list2,list3]}
	end

	def handle_cast({:nodeMUnsync, nodeM}, [list, list2, list3]) do
		updated_listNodesM = Enum.map(list, fn x -> nodeStateFunction(nodeM, :UNSYNC, x) end)
		{:noreply, [updated_listNodesM,list2,list3]}
	end

	def handle_cast({:nodeUp, node}, [other, list, other2]) do
		updated_listNodes = Enum.map(list, fn x -> nodeStateFunction(node, :UP, x) end)
		{:noreply, [other,updated_listNodes,other2]}
	end

	def handle_cast({:nodeDown, node}, [other, list, other2]) do
		updated_listNodes = Enum.map(list, fn x -> nodeStateFunction(node, :DOWN, x) end)
		{:noreply, [other,updated_listNodes,other2]}
	end

	def init([nodesMaster, nodesList, nodesFiles]) do
		{:ok, [nodesMaster, nodesList, nodesFiles]}
	end
end