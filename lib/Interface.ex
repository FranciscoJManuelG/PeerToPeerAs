defmodule Interface do
	alias ServerWIP, as: Server

	# Ejecuta ordenes provenientes de nodos base
	def execute_client(orden, name, ip) do
		case String.split(orden) do
			["CONNECT"] -> 			if not Server.isNodeUp(name) do
										Server.addNode(name, ip)
										Server.nodeUp(name)
									else IO.puts("YA ESTAS CONECTADO")
									end
			["DISCONNECT"] -> 		if Server.isNodeUp(name) do
										Server.nodeDown(name)
									else IO.puts("NO ESTAS CONECTADO")
									end
			["WANT", fileId] -> 	if Server.isNodeUp(name) do
										Server.want(fileId)
									else IO.puts("NO ESTAS CONECTADO")
									end
			["OFFER", fileId] -> 	if Server.isNodeUp(name) do
										Server.offer(fileId, name)
									else IO.puts("NO ESTAS CONECTADO")
									end
			_-> IO.puts("FORMAT INCORRECT")
		end
	end

	# Ejecuta ordenes provenientes de administradores
	def execute_admin(orden) do
		case String.split(orden) do
			["START"] -> Server.start()
			["STOP"] -> Server.stop()
			["ADD", "NODE", nodeId, nodeIp] -> Server.addNode(nodeId,nodeIp)
			["ADD", "NODEM", nodeMId, nodeMIp] -> Server.addNodeM(nodeMId,nodeMIp)
			["ADD", "FILE", fileId] -> Server.addFile(fileId)
			["ADD", "NODES_TO_FILE", fileId, nodes] -> Server.addNodesToFiles(fileId,String.split(nodes,"-"))			
			["REMOVE", "NODEM", nodeMId] -> Server.removeNodeM(nodeMId)
			["REMOVE", "NODE", nodeId] -> Server.removeNode(nodeId)
			["REMOVE", "FILE", fileId] -> Server.removeFile(fileId)
			["REMOVE", "NODES_TO_FILE", fileId, nodes] -> Server.removeNodesOfFile(fileId,String.split(nodes,"-"))	
			["VIEW","NODES"] -> Server.viewNodes()
			["VIEW","NODESM"] -> Server.viewNodesM()
			["VIEW","NODESM","IPS"] -> Server.viewNodesMIp()
			["VIEW","NODES","IPS"] -> Server.viewNodesIp()
			["VIEW","FILES"] -> Server.viewFiles()
			["VIEW"] -> Server.viewAll()
			["NODE","UP",nodeId] -> Server.nodeUp(nodeId)
			["NODE","DOWN",nodeId] -> Server.nodeDown(nodeId)
			["NODE","SYNC",nodeMId, listSync] -> Server.nodeMSync(nodeMId, listSync) #No funciona
			["NODE","UNSYNC",nodeMId] -> Server.nodeMUnsync(nodeMId)
			_-> IO.puts("FORMAT INCORRECT")
		end
	end

end

# import Interface
# execute_admin("START")
# execute_admin("ADD NODE Node1 10.10.10.10")
# execute_admin("ADD NODE Node2 20.10.10.10")
# execute_admin("VIEW NODES IPS")
# execute_admin("ADD NODEM NodeM1 33.33.33.33")
# execute_admin("VIEW NODESM IPS")
# execute_admin("NODE UP Node1")
# execute_admin("NODEM SYNC NodeM1 []")
# execute_admin("VIEW NODES IPS")
# execute_admin("VIEW NODESM IPS")
# execute_admin("ADD FILE File1")
# execute_admin("ADD NODES_TO_FILE File1 Node1-Node2")
# execute_admin("VIEW FILES")
# execute_admin("REMOVE NODES_TO_FILE File1 Node1-Node2")
# execute_admin("VIEW FILES")
# execute_admin("REMOVE NODEM NodeM1")
# execute_admin("REMOVE NODE Node2")
# execute_admin("REMOVE FILE File1")
# execute_admin("VIEW")
# execute_admin("STOP")
